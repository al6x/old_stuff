# You can use 
# children :first, :@second
# notion.
#
module WigetContainer			
	def self.included klass; klass.extend(ClassMethods) end
	
	module ClassMethods		
		def children *args
			@self_children_as_variables, @self_children_as_methods = [], []
			args.each do |child|
				if child.to_s =~ /^@/					
					@self_children_as_variables << child.to_s
				else					
					@self_children_as_methods << child
				end
			end
		end
		
		def children_as_methods
			parent = ancestors.find{|a| a.is?(WigetContainer) and a != self and a != WigetContainer}			
			
			if parent 
				if parent.children_as_methods and @self_children_as_methods 
					return parent.children_as_methods + @self_children_as_methods
				elsif parent.children_as_methods
					return parent.children_as_methods
				else
					@self_children_as_methods
				end
			else
				return @self_children_as_methods
			end
		end
		
		def children_as_variables		
			parent = ancestors.find{|a| a.is?(WigetContainer) and a != self and a != WigetContainer}			
			
			if parent 
				if parent.children_as_variables and @self_children_as_variables
					return parent.children_as_variables + @self_children_as_variables
				elsif parent.children_as_variables
					return parent.children_as_variables
				else
					return @self_children_as_variables
				end
			else
				return @self_children_as_variables		
			end
		end
		
		def children_defined?; children_as_variables || children_as_methods end
	end		
	
	# Iterates over all Wiget and Arrays (also multidimensional) of Wigets listened in children method
	def each_child &block		
		v_processed, m_processed = Set.new, Set.new
		if self.class.children_defined?
			if self.class.children_as_methods
				self.class.children_as_methods.each do |m|
					next if m_processed.include? m
					m_processed.add m      
					
					value = send m
					next unless value
					if value.is_a? Array
						WigetContainer.visit_array_multidimensional value, block
					else
						block.call value
					end
				end
			end
			if self.class.children_as_variables
				self.class.children_as_variables.each do |v|
					next if v_processed.include? v
					v_processed.add v
					
					value = instance_variable_get v
					next unless value
					if value.is_a? Array
						WigetContainer.visit_array_multidimensional value, block
					else
						block.call value
					end
				end
			end
		else
			# Iterate over all instance variables that are Wiget and over all arrays that have 
			# first item of type Wiget.
			instance_variables.each do |v|
				next if v_processed.include? v
				v_processed.add v                    
				
				value = instance_variable_get v
				next unless value
				if value.is_a?(Array) and value.size > 0 and value[0].is_a?(Wiget)
					value.each{|item| block.call item}
				elsif value.is_a? Wiget
					block.call value
				end
			end			
		end						
	end
	
	def visit visitor				
		if visitor.accept self
			each_child do |c|
				if $debug and !c.is_a?(Wiget)
					raise "Component '#{self}' of '#{self.class}' Class has '#{c}' \
of '#{c.class.name}' Class among it's Children!" 
				end
				c.visit visitor
			end
		end			
		return visitor
	end
	
	protected
	class << self
	def visit_array_multidimensional array, block
		array.each do |value|
			if value.is_a? Array
				visit_array_multidimensional value, block
			else
				block.call value if value
			end
		end
	end
	end
end