module WGUI	
	Cache.cached :class, Core::WigetContainer::ClassMethods, :children_as_methods, :children_as_variables
	Cache.cached_with_params :class, Engine::StaticResource, :lookup_resource, :header
end
