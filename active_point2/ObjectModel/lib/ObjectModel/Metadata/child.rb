module ObjectModel
	class Metadata
		class Children < Hash
			def initialize
				super{should! :be_never_called}
			end
			
			def copy
				c = Children.new
				each{|n, m| c[n] = m.copy}
				return c
			end
			
			def inherit parent
				parent.copy.merge copy
			end												
		end
		
		class Child
			include OpenConstructor
			
			attr_accessor :name, :ivname, :title, :type, :parameters
			
			def copy; clone end
		end
		
		definition[:children] = Object.new.singleton_class do
			def initial_value klass; Children.new end
			
			def copy children; children.copy end
			
			def inherit pvalue, cvalue;  
				cvalue.inherit pvalue
			end						
		end
		
		attr_accessor :children
		
		class DSL
			def child name, type = :single, other = {}				
				type.should! :be_in, Metadata::CHILD_TYPES_SHORTCUTS
				values = {:name => name, :ivname => name.to_iv, :type => Metadata::CHILD_TYPES_SHORTCUTS[type]}.merge(other)
				child = Child.new.set_with_check values				
				@meta.children[name] = child
				
				@klass._define_child child
			end
		end
	end
end