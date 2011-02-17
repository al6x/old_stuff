class TestServer < WComponent	
	extend Managed
	include WPortlet
	
	scope :session
	
	children :wiget

	def self.state_conversion_strategy
		Engine::State::StringStateConversionStrategy
	end

	def initialize
		self.component_id = "t"
	end
	
	def update_state
		wiget = TestServer.registry[state].call
		raise "Invalid wiget for test in '#{state}' Spec!" unless wiget.is_a? Core::Wiget
		@current =  wiget
	end
	
	def wiget 
		@current
	end

	def self.registry
		@registry ||= Hash.new(lambda{Label.new("Wiget isn't setted!")})
	end	
end

class ::Object
	def start_webserver app = TestServer, root = nil
		WGUI::Engine::Runner.start app, root
	end

	def stop_webserver		
		WGUI::Engine::Runner.stop
	end

	def join_webserver
		WGUI::Engine::Runner.join
	end

	def register_wiget name, &block
		TestServer.registry[name] = block
	end
end