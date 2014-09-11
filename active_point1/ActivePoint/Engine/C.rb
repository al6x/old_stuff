class C
	extend Injectable
	inject :ap_controller => APController,	:controller => :controller
	
	def object= object
		ap_controller.object = object
	end
	
	def object
		ap_controller.object
	end	
	
	def transaction_begin
		Scope.begin :transaction
	end
	
	def user
		R.by_id Scope[:user]
	end
	
	def can? permission_name
		user.can? permission_name, object.effective_policy
	end
	
	def class
		controller.class
	end
	
	def services
		Scope[Services]
	end
	
	def anonymous?
		Scope[:user] == Core::Users::Model::AnonymousUser::ID
	end
	
	def method_missing m, *args, &b
		if controller.respond_to? m
			controller.send m, *args, &b
		else
			super
		end
	end
	
	def respond_to? m
		controller.respond_to? m
	end		
end