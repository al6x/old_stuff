module Configurator				
	def depends_on *args
		if args.size == 0
			@depends_on ||= []
		else
			@depends_on = args
		end		
	end
	
	def activate &b
		@activate = b
	end
	
	def activate!
		@activate.call if @activate		
	end
	
	def startup &b		
		@startup = b
	end
	
	def startup!
		@startup.call if @startup
	end
	
	def teardown &b
		@teardown = b
	end
	
	def teardown!
		@teardown.call if @teardown
	end
	
	def restart &b
		@restart = b
	end
	
	def restart!
		@restart.call if @restart
	end		
	
	def initialized?
		R.get(key) == "true"
	end
	
	def initialize_data &b
		@initialize_data = b
	end		
	
	def initialize_data!			
		should_not! :initialized?
		@initialize_data.call if @initialize_data
		R.put key, "true"	
	end
	
	def clear_data &b				
		@clear_data = b		
	end
	
	def clear_data!
		should! :initialized?
		@clear_data.call if @clear_data
		R.put key, "false"
	end
	
	protected
	def key
		"#{self.name} Plugin Initiallized"
	end
end