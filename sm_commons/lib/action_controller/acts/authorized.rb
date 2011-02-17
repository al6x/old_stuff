module ActionController
  module Acts
    module Authorized
    
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_authorized
          include ActionController::Acts::Authorized::InstanceMethods
          extend ActionController::Acts::Authorized::SingletonMethods
          helper_method :can?, :owner?
        end
      end
  
      module SingletonMethods
        def require_permission operation, *args, &object_proc
          operation = operation.to_s.should! :be_a, [String, Symbol]
          # operation.should! :be_in, Space.permissions
          
          options = args.extract_options!
          # object_proc = args.size > 0 ? args.first : lambda{}
          object_proc ||= lambda{}
          
          method = "require_permission_#{operation}"
          define_method method do
            require_permission operation, instance_eval(&object_proc)
          end
          before_filter method, options
        end
        # alias_method :require_permission_to, :require_permission
      end
  
      module InstanceMethods
        protected
          def can? *args
            User.current.can? *args
          end          
          
          def owner? *args
            User.current.owner? *args
          end
          
          def login_required
            access_denied! unless User.current.registered?
          end
  
          def login_not_required
            raise_user_error t(:login_not_required) if User.current.registered?
          end
        
          def require_permission operation, object = nil
            operation = operation.to_s.should! :be_a, [String, Symbol]
            # operation.should! :be_in, Space.permissions
                      
            unless User.current.can? operation, object
              Rails.logger.warn "Access denied, #{User.current.name} hasn't rights to #{operation}!"
              access_denied!
            end
          end
          
          def access_denied!            
            raise_user_error t(:access_denied)
          end
  
          # def access_denied
          #   respond_to do |format|
          #     format.html do
          #       flash[:info] = t(:login_required)
          #       session[:_return_to] = request.request_uri
          #       redirect_to new_session_path
          #     end
          #   
          #     format.any(:json, :xml) do
          #       request_http_basic_authentication 'Web Password'
          #     end
          #   end
          # end
      end
    end
  end
end
ActionController::Base.send :include, ActionController::Acts::Authorized