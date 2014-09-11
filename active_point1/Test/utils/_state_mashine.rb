module ::Utils
	class StateMashine
		attr_accessor :object
		
		def initialize object = nil; 
			@object = object
			@on_entry, @on_exit = {}, {}
			self.state = self.class.initial_state_get if self.class.initial_state_get
		end
	
		def on_entry state, method
			if method
				@on_entry[state] = method
			else
				@on_entry.delete state
			end
		end
	
		def on_exit state, method
			if method
				@on_exit[state] = method
			else
				@on_exit.delete state
			end
		end		
	
		def method_missing m, *args, &b
			from, to = self.class.actions_get[m]
			raise RuntimeError, "Invalid State Transfer Method: '#{m}'!", caller(1) unless from
			if from != state
				raise RuntimeError, "Can't call Transfer Method '#{m}' in '#{state}' State!", caller(1)
			end
			self.state = to
		end
	
		def == other
			return true if equal? other
			return state == other if other.is_a? Symbol
			return state == other.state if other.is_a? StateMashine
			return false
		end
	
		def state; @state end
	
		def state= new_state
			froms = self.class.transitions_get[new_state]
			if state and (!froms or !froms.include?(self.state))
				raise RuntimeError, "Can't transit from :#{state} to :#{new_state}!", caller(1)
			end
			@object.send(@on_exit[state]) if state and @object and @on_exit.include? state
			@object.send(@on_entry[new_state]) if @object and @on_entry.include? new_state
			@state = new_state
		end
		
		class << self
			def transitions_get; @transitions end
			def actions_get; @actions end
			def initial_state_get; @initial end
		
			def transitions *args			
				@transitions, @actions = {}, {}
				args.each do |line|
					from, action, to = line
					
					@transitions ||= {}
					@actions ||= {}
			
					@transitions[to] ||= []
					@transitions[to] << from
					@actions[action] = from, to
				end
			end
		
			def initial state; @initial = state end					
        end
	end
end