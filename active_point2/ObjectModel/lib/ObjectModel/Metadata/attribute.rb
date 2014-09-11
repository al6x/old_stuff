module ObjectModel
	class Metadata
		class Attributes < Hash
			def initialize
				super{should! :be_never_called}
			end
			
			def copy
				c = Attributes.new
				each{|n, m| c[n] = m.copy}
				return c
			end
			
			def inherit parent
				parent.copy.merge copy
			end		
		end
		
		class Attribute
			include OpenConstructor
			
			attr_accessor :name, :ivname, :title, :type, :initialize, :parameters, :validate
			public :initialize
			
			def copy; clone end
		end
		
		definition[:attributes] = Object.new.singleton_class do
			def initial_value klass; Attributes.new end
			
			def copy attributes; attributes.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end						
		end
		
		attr_accessor :attributes
		
		class DSL
			def attribute name, type = :object, other = {}				
				type.should! :be_in, Metadata::ATTRIBUTE_TYPES_SHORTCUTS
				values = {
					:name => name, 
					:ivname => name.to_iv, 
					:type => Metadata::ATTRIBUTE_TYPES_SHORTCUTS[type],
					:initialize => NotDefined
				}.merge(other)
				attr = Attribute.new.set_with_check values				
				@meta.attributes[name] = attr
				
				@klass._define_attribute attr
			end
		end
	end
end