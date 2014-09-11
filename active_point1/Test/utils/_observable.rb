module ::Utils
	module Observable		
		class Caller
			attr_reader :observer
		
			def initialize observer, method, condition
				@observer, @method, @condition = observer, method, condition
			end
		
			def call *args
				if !@condition or (@condition and @condition.call(*args))
					if @observer
						if @method 
							@observer.send(@method, *args)
						else
							@observer.send(:update, *args)
						end
					end
				end
			end
		end
	
		def add_observer observer = nil, method = nil, &condition
			@variable_observers ||= []
			@variable_observers << Caller.new(observer, method, condition)
		end
	
		def notify_observers *args
			if defined? @variable_observers			
				if args.size > 0
					@variable_observers.each{|caller| caller.call(*args)} 
				else
					@variable_observers.each{|caller| caller.call self} 
				end
			end
		end
	
		def delete_observer observer
			@variable_observers.delete_if{|caller| caller.observer.equal? observer } if @variable_observers
		end
	
		def delete_observers
			@variable_observers.clear if defined? @variable_observers
		end
	
		def observers_count
			@variable_observers.size if defined? @variable_observers
		end
	end
end