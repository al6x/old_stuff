$debug = true
if $debug
	warn 'DEBUG MODE'
	
	#require 'ruby-debug'
	
	Thread.abort_on_exception = true
	
	RubyExt::ClassLoader.error_on_defined_constant = true
	
	module Kernel
		STACK_TRACE_EXCLUDE = [
		/\/rspec/, 
		/\/ruby-debug/, 
		/\/monitor.rb/, 
		/\/timeout.rb/,
#				/gems/, 
		#		/WGUI/,
		/\/MicroContainer/,
		/\/RubyExt/,
		/\/kernel.rb/,
		/\/mongrel/,
		/\/rack/,
		/\/sync/,
		/\/require/,
		/\/site_ruby/,
		]
		
		alias_method :old_caller, :caller
		def caller int = 0
			stack = old_caller  
			stack = stack[(int+1)..stack.size].delete_if do |line|
				STACK_TRACE_EXCLUDE.any?{|re| line =~ re}
			end
			return stack
		end
		
		def where?
			puts "\nwhere:"
			puts caller
		end
		
#		alias_method :old_raise, :raise
#		def raise *p
#			case p.size
#				when 3
#				e, m, c = p
#				when 2
#				e, m = p
#				c = caller
#				when 1					
#				if p[0].is_a? Exception
#					e = p[0].class
#					m = p[0].message					
#				else
#					e = RuntimeError
#					m = p[0]				
#				end
#				c = caller
#				when 0
#				e, m, c = RuntimeError, "", caller
#			else 
#				old_raise "Invalid Usage!"
#			end
#			old_raise e, m, c
#		end
	end				
end
#def p; end