module ObjectModel
	class Metadata
		class References < Hash
			def initialize
				super{should! :be_never_called}
			end
			
			def copy
				c = References.new
				each{|n, m| c[n] = m.copy}
				return c
			end
			
			def inherit parent
				parent.copy.merge copy
			end			
		end
		
		class Reference
			include OpenConstructor
			
			attr_accessor :name, :ivname, :title, :type, :parameters
			
			def copy; clone end
		end
		
		definition[:references] = Object.new.singleton_class do
			def initial_value klass; References.new end
			
			def copy references; references.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end						
		end
		
		attr_accessor :references
		
		class DSL
			def reference name, type = :single, other = {}				
				type.should! :be_in, Metadata::REFERENCE_TYPES_SHORTCUTS
				values = {:name => name, :ivname => name.to_iv, :type => Metadata::REFERENCE_TYPES_SHORTCUTS[type]}.merge(other)
				ref = Reference.new.set_with_check values				
				@meta.references[name] = ref
				
				@klass._define_reference ref
			end
		end
	end
end