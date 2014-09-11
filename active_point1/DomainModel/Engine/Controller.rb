class Controller
  extend Managed
  scope :session
  
  inject :object_context => WebClient::ObjectContext, 
  :cp_controller => WebClient::Controller, 
  :cp_window => WebClient::Window, :object => :object, :view => :view
  
  def initialize
    super    
    @stack = []
    @state = ControllerState.new
    
    # Events
    @state.on_entry(:Initial){@stack.clear}    
    
    bcancel = lambda do 
      Scope.custom_scope_set :view, object_context.saved_view
      view.refresh
    end    
    @state.on_event :Action, :cancel, &bcancel    
    @state.on_event :NestedAction, :cancel, &bcancel    
    
    @state.on_event :Action, :end do 
      a = @stack.pop
      DomainModel::Transactional.commit
      a.respond_to :choose_next
    end
    @state.on_event(:View, :end){@stack.pop}
    
    @state.on_event :NestedAction, :end do
      @stack.pop
      @stack.last.respond_to :resume
    end
    
    @state.on_event(:View, :begin){object_context.saved_view = Scope.custom_scope_get :view}    
  end
  
  def execute name, params = {}    
    @state.event :begin                 
    action = DomainModel::Actions::Action.build name, {:object => object}.merge(params)
    @stack << action        
    action.execute 
  end
  
  def finish        
    @state.event :end
  end
  
  def cancel
    @state.event :cancel
  end   
  
  def user= user
    raise "Not implemented!"
  end      
  
  def object= object
    @state.event :go_to
    cp_controller.object = object
  end       
  
  def view= view
    cp_controller.view = view
  end    
end