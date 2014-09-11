class Listener		
	def after_new_parent entity, old_parent
		entity._effective_permission_cache_clear
	end
	
	def after_delete_parent entity, old_parent
		entity._effective_permission_cache_clear
	end	
end