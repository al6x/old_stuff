class Wiget
	inherit Entity
	
	metadata do
		name "Wiget"
		attribute :wiget_class, :class
		attribute :accessor, :object
		attribute :parameters, :object
		attribute :storage, :object
		
		after :commit, :register_wiget
	end
	
	def create_wiget_wrapper				
		WGUIExt::Containers::Wrapper.new.set! :component => name, :accessor => accessor
	end
	
	def register_wiget		
		if wiget_class			
			Scope.should! :include, wiget_class
			scope, initializer = Scope.registry wiget_class
			Scope.register name, scope do
				wiget = wiget_class.new				
				wiget.set! parameters if parameters
				wiget.respond_to :wiget_id=, self.entity_id
				wiget
			end
		end
	end
end