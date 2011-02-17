class Development
	inherit RestController
	
	def reset_data!
		Engine.reset_data!
	end
	
	def eval code
		Kernel.eval code, TOPLEVEL_BINDING, __FILE__, __LINE__
	end
	
	secure :reset_data! => :development, :eval => :development	
end