module ObjectModel
	class Metadata
		class BaseEvents < Hash
			def initialize
				super{should! :be_never_called}
			end
			
			def copy
				c = self.class.new
				each{|n, m| c[n] = m.clone}
				return c
			end
			
			def inherit parent
				r = parent.copy
				copy.each do |n, m|
					if r.include? n
						r[n] += m
					else
						r[n] = m
					end
				end
				return r
			end								
		end
		
		class BeforeEvents < BaseEvents
			def fire entity, event_name, *params
				event_name.should! :be_in, Metadata::BEFORE_EVENT_TYPES
				if self.include? event_name
					self[event_name].each{|event| event.fire entity, *params}
				end
			end
		end
		
		class AfterEvents < BaseEvents
			def fire entity, event_name, *params
				event_name.should! :be_in, Metadata::AFTER_EVENT_TYPES
				if self.include? event_name
					self[event_name].each{|event| event.fire entity, *params}
				end
			end
		end
		
		class Event
			attr_reader :method, :block
			
			def initialize method = nil, &block
				if method
					method.should! :be_a, Symbol
					block.should! :be_nil
					@method = method					
				elsif block
					method.should! :be_nil
					@block = block
				else
					should! :be_never_called
				end
			end
			
			def fire entity, *params
				if @method
					entity.send @method, *params
				elsif @block
					entity.instance_eval &@block
				else
					should! :be_never_called
				end
			end
		end
		
		definition[:before] = Object.new.singleton_class do
			def initial_value klass; BeforeEvents.new end
			
			def copy events; events.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end
		end
		
		definition[:after] = Object.new.singleton_class do
			def initial_value klass; AfterEvents.new end
			
			def copy events; events.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end
		end
		
		attr_accessor :before
		attr_accessor :after
		
		class DSL			
			def after name, method = nil, &block
				name.should! :be_in, Metadata::AFTER_EVENT_TYPES
				e = Event.new method, &block
				@meta.after[name] = [e]
			end
			
			def before name, method = nil, &block
				name.should! :be_in, Metadata::AFTER_EVENT_TYPES
				e = Event.new method, &block
				@meta.before[name] = [e]
			end
		end
	end
end