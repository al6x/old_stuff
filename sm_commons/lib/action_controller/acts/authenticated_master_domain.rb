module ActionController
  module Acts
    module AuthenticatedMasterDomain
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_authenticated_master_domain
          include ::ActionController::Acts::AuthenticatedMasterDomain::InstanceMethods
                    
          helper_method :login_path, :logout_path, :signup_path, :user_path
          before_filter :prepare_current_user_for_master_domain
        end
      end
      
      module InstanceMethods           
        include ::ActionController::Acts::Authenticated::InstanceMethods
        
        protected     
          def prepare_current_user_for_master_domain
            user = login_from_basic_auth || login_from_session || login_from_cookie || login_as_anonymous
            raise "You probably don't create Anonymous User!" if user.nil?
            User.current = user
          end

          
          # 
          # Authentication Methods
          # 
          def login_from_cookie
            token = !cookies[:auth_token].blank? && SecureToken.by_token(cookies[:auth_token])
            if token and !token[:user_id].blank? and (user = User.first(:id => token[:user_id], :state => 'active'))
              session[:user_id] = user.id.to_s
              user
            end
          end
          
          
          # 
          # CAS Authentication
          # 
          
          # returns cas_token only for another domains
          def return_to_path_with_cas_token
            unless master_domain? params[:_return_to]
              token = SecureToken.new
              token.expires_at = 5.minutes.from_now
              token[:type] = 'cas'
              token[:user_id] = User.current.id.to_s
              token.save!
          
              return return_to_path(:cas_token => token.token)
            end
            
            return_to_path
          end
          
          def return_to_path_with_logout_cas_token
            unless master_domain? params[:_return_to]
              return_to_path(:cas_logout => 'true')
            else
              return_to_path
            end
          end
          
          def return_cas_token_if_authenticated
            redirect_to return_to_path_with_cas_token unless User.current.anonymous?
          end
          
          
          # 
          # Special
          # 
          def master_domain? uri
            unless uri.blank?
              uri = Uri.parse(uri)
              
              if !uri.host.blank? and uri.normalized_host != SETTING.master_domain!                             
                return false
              end
            end
            true
          end
          
          def set_current_user_with_updating_session user
            current_user = User.current
            user.should_not! :==, current_user

            # Clear
            clear_session!
            unless current_user.anonymous?
              SecureToken.delete_all :user_id => current_user.id.to_s
              cookies.delete :auth_token               
            end

            # Set session and cookie token
            session[:user_id] = user.id.to_s      
            unless user.anonymous?
              token = SecureToken.new
              token[:user_id] = user.id.to_s
              token[:type] = 'cookie_auth'
              token.expires_at = 2.weeks.from_now
              token.save!

              cookies[:auth_token] = {:value => token.token, :expires => token.expires_at}
            end

            User.current = user
          end
      end
      
    end
  end
end
ActionController::Base.send :include, ActionController::Acts::AuthenticatedMasterDomain