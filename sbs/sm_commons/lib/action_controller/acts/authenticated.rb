module ActionController
  module Acts
    module Authenticated
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_authenticated
          include ActionController::Acts::Authenticated::InstanceMethods
                    
          helper_method :login_path, :logout_path, :signup_path, :user_path
          before_filter :prepare_current_user_for_slave_domain
        end
      end
      
      module InstanceMethods           
        protected     
          def prepare_current_user_for_slave_domain
            unless check_and_execute_cas_command
              user = login_from_basic_auth || login_from_session || login_as_anonymous
              raise "You probably don't create Anonymous User!" if user.nil?
              User.current = user
            end
          end

          
          # 
          # Authentication Methods
          # 
          def login_from_basic_auth
            authenticate_with_http_basic do |login, password|
              User.authenticate_by_password login, password unless login.blank? or password.blank?
            end
          end
          
          def login_from_session
            User.find_by_id session[:user_id] unless session[:user_id].blank?
          end
          
          def login_as_anonymous
            session[:user_id] = User.anonymous.id.to_s
            User.anonymous
          end
          
          
          # 
          # CAS Authentication
          # 
          def check_and_execute_cas_command
            return unless params.include?('cas_token') or params.include?('cas_logout')
            
            if params.include?('cas_token')
              token = !params[:cas_token].blank? && SecureToken.by_token(params[:cas_token])
              clear_session!
              if token and !token[:user_id].blank? and (user = User.first(:id => token[:user_id], :state => 'active'))                
                session[:user_id] = user.id.to_s
              else
                session[:user_id] = User.anonymous.id.to_s
                flash[:sticky_info] = t(:cas_try_more)
              end                            
            elsif params.include? 'cas_logout'              
              clear_session!
              login_as_anonymous
            end
            
            # redirect to remove CAS params
            uri = Uri.parse request.url
            values = uri.query_values || {}
            values.delete 'cas_logout'
            values.delete 'cas_token'
            uri.query_values = values
            
            redirect_to uri.to_s
          end
          
          
          # 
          # Helpers
          # 
          %w{login logout signup}.each do |path|
            define_method "#{path}_path" do |*args|
              options = args.first || {}
              options = {
                :host => SETTING.master_domain!,
                :port => SETTING.port(nil),
                :l => I18n.locale
              }.merge(options)        
              options[:_return_to] = request.url unless params.include? :_return_to
              url_for_path "#{ServiceMix.relative_url_root}/#{path}", options
            end
          end          
        
          def user_path user, options = {}
            url_for_path "#{ServiceMix.relative_url_root}/users/#{user.to_param}", options
          end
          
          
          # 
          # Special
          # 
          PRESERVE_SESSION_KEYS = %w{session_id _csrf_token}
          def clear_session!        
            session[:dumb_key] # hack, need this to initialize session, othervise it's empty               
            to_delete = session.keys.select{|key| !PRESERVE_SESSION_KEYS.include?(key.to_s)}
            to_delete.each{|key| session.delete key}
          end
      end
      
    end
  end
end
ActionController::Base.send :include, ActionController::Acts::Authenticated