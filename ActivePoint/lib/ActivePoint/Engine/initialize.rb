module ActivePoint	
	extend Log			
	
	MODEL_NAME = "Model"
	OBJECT_MODEL_NAME = "Repository"
		
	def self.run *args
		Engine.activate *args
		Engine.join
	end
end

Cache.cached_with_params :class, ActivePoint::Engine::Extensions.singleton_class, :controller_for	