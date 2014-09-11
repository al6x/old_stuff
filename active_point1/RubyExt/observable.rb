module RubyExt
	module Observable								
		def add_observer observer
			@observable_observers ||= []
			@observable_observers << observer unless @observable_observers.include? observer			
		end
		
		def notify_observers method, *args
			method.should! :be_a, Symbol
			@observable_observers.each{|observer| observer.respond_to method, *args} if @observable_observers			
		end
		
		def delete_observer observer
			@observable_observers.delete observer if @observable_observers
		end
		
		def delete_observers			
			@observable_observers.clear if @observable_observers
		end
		
		def observers_count
			@observable_observers ? @observable_observers.size : 0
		end
	end
end