class Nodes
  inherit Rad::Controller::Http
  
  # support for polymorphic route
  before do |c|    
    model = workspace.model        
    model ||= Models::Node.by_param workspace.params.id if workspace.params.id?
    c.instance_variable_set '@model', model
  end
  
  layout '/layout'
  
  def all
    @models = model_class.all.limit(rad.blog.collection_limit).order_by([[:created_at, :desc]])
  end
  
  def show
    render :not_found unless @model
  end
  
  def new
    @model = model_class.new
  end  
  
  def create
    @model = model_class.new params.model    
    if @model.save
      flash.info = t :"#{model_class.alias.underscore}_created"
      redirect_to(path(@model))
    else
      render action: :new
    end
  end
  
  def edit
  end
  
  def update
    if @model.update_attributes params.model
      flash.info = t :"#{model_class.alias.underscore}_updated"
    else
      render action: :edit
    end
  end
  
  def destroy    
    @model.destroy
    flash.info = t :"#{model_class.alias.underscore}_destroyed"
    redirect_to(rad.router.default_path)
  end
    
  def self.model_class
    @model_class ||= "Models::#{self.alias.singularize}".constantize
  end
  
  protected
    def model_class; self.class.model_class end
    helper_method :model_class
    
    def prepare_locale
      # removing :l parameter if it's the same as default language
      redirect_to url_for(workspace.action, l: nil) if params.l.try(:to_sym) == rad.environment.language

      I18n.locale = params.l || rad.environment.language      
    end
    before :prepare_locale
end