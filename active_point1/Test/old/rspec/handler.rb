require 'howt/selenium_adapter'

module Spec
	module Expectations   
    
		class WaitForExpectationMatcherHandler        
			class << self
				include MatcherHandlerHelper
				def handle_matcher(actual, matcher, &block)
					unless matcher.respond_to?(:matches?)
						raise InvalidMatcherError, "Expected a matcher, got #{matcher.inspect}."
					end
					
					match = WaitFor.wait_for{matcher.matches?(actual, &block)}         					
		  
					::Spec::Matchers.generated_description = "should #{describe_matcher(matcher)}"
					Spec::Expectations.fail_with(matcher.failure_message) unless match
				end
			end
		end

		class NegativeWaitForExpectationMatcherHandler
			class << self
				include MatcherHandlerHelper
				def handle_matcher(actual, matcher, &block)
					unless matcher.respond_to?(:matches?)
						raise InvalidMatcherError, "Expected a matcher, got #{matcher.inspect}."
					end

					unless matcher.respond_to?(:negative_failure_message)
						Spec::Expectations.fail_with(
							<<-EOF
Matcher does not support should_not.
See Spec::Matchers for more information
about matchers.
							EOF
						)
					end
					
					match = !WaitFor.wait_for{!matcher.matches?(actual, &block)}						
					
					::Spec::Matchers.generated_description = "should not #{describe_matcher(matcher)}"
					Spec::Expectations.fail_with(matcher.negative_failure_message) if match
				end
			end
		end

	end
end