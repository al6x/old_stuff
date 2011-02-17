module ObjectModel
	class Metadata
		definition[:name] = Object.new.singleton_class do
			def initial_value klass; klass.name end
			
			def copy value; value.clone end
			
			def inherit pvalue, cvalue; cvalue end
		end			
		
		attr_accessor :name
		
		class DSL		
			def name name
				name.should_not! :be_nil
				@meta.name = name
			end
		end
	end
end