class Utils
	class TimeoutError < RuntimeError; end
		
	class TestError < RuntimeError; end
		
	def self.wait_for timeout, retry_timeout, &condition
		timeout.should! :be_a, Numeric
		retry_timeout.should! :be_a, Numeric
		
		start_time = Time.new
		e = TimeoutError.new("Waitings for specified Condition is out!")
		while Time.new - start_time <= timeout do
			begin
				result = condition.call				
				return result if result == true
				raise "Invalid return value (should be true or false but is '#{result}')!" unless result == false
			rescue Exception => e
			end
			sleep retry_timeout
		end
		raise e
	end	
	
	def test_error &b
		begin
			b.call
		rescue Exception => e
			te = TestError.new e.message
			te.set_backtrace e.backtrace
			raise te
		end
	end
end