class SecureWrapper
	def initialize controller
		@controller = controller
	end
	
	def class
		@controller.class
	end
	
	def method_missing m, *args
		if @controller.respond_to? m
			@controller.secure_method_call m, *args
		else
			super
		end
	end
end