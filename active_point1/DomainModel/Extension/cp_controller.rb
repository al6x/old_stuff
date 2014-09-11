#::WebClient::Engine::Controller
#
#module ::WebClient
#  
#  module Engine
#    
#    class Controller
#      inject :object_context => ObjectContext
#      
#      def action_begin name, params = {}		
#        save_view if action_stack.empty?
#        action = DomainModel::Actions::Action.build name, {:object => object}.merge(params)
#        action_stack << action		
#        action.execute
#      end
#      
#      def save_view
#        object_context.saved_view = Scope.custom_scope_get :view
#      end
#      
#      def restore_view
#        Scope.custom_scope_set :view, object_context.saved_view
#        view.refresh
#      end
#      
#      def action_cancel
#        action_stack.clear
#        restore_view
#      end 
#      
#      def action_end
#        finished = action_stack.pop
#        
#        if action_stack.empty?
#          #					DomainModel::Transactional.commit
#          action_begin finished.next_view if finished.next_view
#        else					
#          action_stack.last.respond_to :resume, finished
#        end								
#      end
#      
#      def user= user
#        Scope.begin :user
#        Scope[:user] = user
#        self.object = object
#      end      
#      
#      def object= object
#        set_object object
#      end   
#      
#      def view= view
#        Scope.begin :view
#        Scope[:view] = view
#        Scope[:view].refresh
#      end  
#      
#      def action_stack
#        @action_stack ||= []
#      end
#    end
#  end
#end