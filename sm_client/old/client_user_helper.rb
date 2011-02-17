module Authentication
  module ClientUserHelper
    
    def self.included(recipient)
      recipient.extend(ClassMethods)
    end
    
    module ClassMethods
      def current= current
        Thread.current[name] = current
      end

      def current
        Thread.current[name].should_not! :be_nil
      end
    end
  end
end