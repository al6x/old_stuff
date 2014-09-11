class Module
	def namespace
		if @module_namespace_defined
			@module_namespace
		else
			@module_namespace_defined = true
			list = self.name.split("::")
			if list.size > 1
				list.pop
				@module_namespace = eval(list.join("::"))
			else
				@module_namespace = nil
			end
		end
	end
end