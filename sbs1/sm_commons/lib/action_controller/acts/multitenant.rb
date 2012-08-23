module ActionController
  module Acts
    module Multitenant
      def self.included(base)
        base.extend(ClassMethods)
      end
            
      module InstanceMethods
        protected        
          def select_account_and_space
            begin
              # preparing Account 
              subdomains = request.subdomains.select{|n| n != 'www'}
              subdomain = subdomains.last          
              pure_domain = request.domain.sub(/\A#{subdomains.join(".")}\./, "")

              domain = subdomain.blank? ? pure_domain : "#{subdomain}.#{pure_domain}"

              Account.current = Account.first :conditions => {:domains => domain}
              unless Account.current?
                msg = "No Account registered for the '#{pure_domain}' Domain"
                logger.debug msg
                raise msg
              end

              # preparing Space
              space_name = params[:s] || 'default'
              Space.current = Account.current.spaces.first :name => space_name

              unless Space.current?
                msg = "No '#{space_name}' Space for '#{Account.current.name}' Account"
                logger.debug msg
                raise msg
              end
            
              yield
            ensure
              Account.current = nil
              Space.current = nil
            end
          end
                
      end
      
      module ClassMethods
        def acts_as_multitenant
          include ActionController::Acts::Multitenant::InstanceMethods
          
          around_filter :select_account_and_space
        end
      end
      
    end
  end
end
ActionController::Base.send :include, ActionController::Acts::Multitenant