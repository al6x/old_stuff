module ActionController
  module Acts
    module SMMicelaneous
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_localized
          include ::ActionController::Acts::SMMicelaneous::InstanceMethods
          
          before_filter :prepare_locale
        end
      end
      
      module InstanceMethods
        protected     
          def prepare_locale
            default_language = (Space.current? ? Space.current.language : nil) || SETTING.default_language('en')
            I18n.locale = params[:l] || default_language
            
            # Delete l from params if language is the same as default
            params.delete 'l' if params[:l] == default_language
          end
      end
      
    end
  end
end
ActionController::Base.send :include, ActionController::Acts::SMMicelaneous