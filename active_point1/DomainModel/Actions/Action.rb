class Action
	include OpenConstructor, Log
	extend Injectable, Log
	
	inject :view => :view, :controller => Engine::Controller, 
	:storage => :storage, :view_context => WebClient::ViewContext
	
	def operation_processor; storage.operation_processor end
	
	attr_accessor :name, :object, :klass		
	
	def cancel
		controller.cancel
	end
	
	def finish
		controller.finish
	end
	
	def next_view
		:on_view
	end	
	
	class << self
		
		def build name, runtime_parameters = nil
			object = runtime_parameters[:object]
			klass = object.class
			
			am = klass.vmeta.actions[name]
			
			begin
				action = am.class.new 
			rescue Exception => e
				log.error "Can't initialize Class for '#{name}' Action!" 
				raise e
			end		
			
			action.name, action.klass, action.object = am.name, klass, object
			
			action.set am.parameters if am.parameters
			action.set runtime_parameters
			
			action.respond_to :build
			return action
		end
		
		def build_control action_name, current_action, parameters = {}
			c = WebClient::Wigets::Controls::Button.new
			c.text = current_action.klass.vmeta.actions[action_name].parameters[:title] unless parameters.include? :title
			c.action = lambda{Scope[Engine::Controller].execute action_name} unless parameters.include? :action
			parameters[:name] = action_name
			c.set parameters
			return c
		end
	end    
	
	def to_s
    "#<#{self.class.name}"
	end
	
	def inspect; to_s end
end