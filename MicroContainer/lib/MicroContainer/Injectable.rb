module Injectable    
	def inject attributes
		raise_without_self "Invalid argument!", MicroContainer \
		unless attributes.is_a? Hash
			attributes.each do |name, specificator|
				raise_without_self "Attribute name should be a Symbol!",
				MicroContainer unless name.is_a? Symbol
				
				if [Class, Module].include? specificator.class
					specificator = specificator.name
				elsif specificator.is_a? Symbol
					specificator = ":#{specificator}"
				else
					specificator = "\"#{specificator}\""
				end
				script = %{\
def #{name}
	::MicroContainer::Scope[#{specificator}]
end

def #{name}= value
	::MicroContainer::Scope[#{specificator}] = value
end}
				class_eval script, __FILE__, __LINE__
			end
		end
		
		def scope_begin method, scope
			alias_method :"scope_begin_#{method}", :"#{method}"
			class_eval %{\
def #{method} *args
	::MicroContainer::Scope.begin :#{scope}
	scope_begin_#{method}(*args)
end
    }, __FILE__, __LINE__
		end
		
		def scope_end method, scope
			alias_method :"scope_end_#{method}", :"#{method}"
			class_eval %{\
def #{method} *args
	::MicroContainer::Scope.end :#{scope}
	scope_end_#{method}(*args)
end
    }, __FILE__, __LINE__
		end
		
		def continuation_begin method, scope
			alias_method :"continuation_scope_begin_#{method}", :"#{method}"
			class_eval %{\
def #{method} *args
	::MicroContainer::Scope.continuation_begin :#{scope}
	continuation_scope_begin_#{method}(*args)
end
    }, __FILE__, __LINE__
		end
		
		def continuation_end method, scope
			alias_method :"continuation_scope_end_#{method}", :"#{method}"
			class_eval %{\
def #{method} *args
	::MicroContainer::Scope.continuation_end :#{scope}
	continuation_scope_end_#{method}(*args)
end
    }, __FILE__, __LINE__
		end
	end