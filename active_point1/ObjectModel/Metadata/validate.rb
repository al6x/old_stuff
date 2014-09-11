module ObjectModel
	class Metadata
		class Validations < Array
			def copy
				self.clone
			end
			
			def inherit parent
				v = Validations.new
				v.replace parent + self
				v
			end								
			
			def validate entity
				every.validate entity
			end
		end
		
		class Validation
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
			
			def validate entity
				if @method
					entity.send @method
				elsif @block
					entity.instance_eval &@block
				else
					should! :be_never_called
				end
			end
		end
		
		definition[:validation] = Object.new.singleton_class do
			def initial_value klass; Validations.new end
			
			def copy validations; validations.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end
		end
		
		attr_accessor :validation
		
		class DSL			
			def validate method = nil, &block
				vs = Validations.new
				vs << Validation.new(method, &block)
				@meta.validation = vs
			end
		end
	end
end