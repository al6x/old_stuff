require 'howt/rspec/handler'

module Spec
	module WaitFor
		def self.timeout= timeout; @@timeout = timeout end
		
		def self.timeout
			raise "Timeout isn't defined!" unless defined? @@timeout
			@@timeout
        end
		
		def self.wait_for &condition
			start_time = Time.new
			while Time.new - start_time <= timeout do
				begin
					return true if condition.call
				rescue Exception
                end
				sleep 0.3
            end
			return false
        end
    end
	
	module Expectations
		module ObjectExpectations
			
			def wait_for_should(matcher = :default_parameter, &block)
				if :default_parameter == matcher
					raise "'wait_for_should' can't support matching by operator!"
				else
					WaitForExpectationMatcherHandler.handle_matcher(self, matcher, &block)
				end
			end

			def wait_for_should_not(matcher = :default_parameter, &block)
				if :default_parameter == matcher
					raise "'wait_for_should_not' can't support matching by operator!"
				else
					NegativeWaitForExpectationMatcherHandler.handle_matcher(self, matcher, &block)
				end
			end

		end
	end
end