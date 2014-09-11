class ExtraBlankSlate < BlankSlate
	CUSTOM_UNDEFINE = [:p, :select, :puts]
		
	undefine = Kernel.instance_methods + Object.instance_methods + CUSTOM_UNDEFINE
	BlankSlate.instance_methods.each{|m| undefine.delete m}
	
	undefine.each do |m|
		script = %{\
def #{m} *p, &b
	method_missing :#{m}, *p, &b
end}
		class_eval script, __FILE__, __LINE__
	end		
end