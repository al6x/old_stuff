module ActivePoint	
	extend Engine::Runner
	
	CORE_PLUGINS = self["core_plugins.rb"]
	CONFIG = Hash.new{should! :be_never_called}.replace(self["default_config.rb"])
	
	# Scopes
	Scope.register :object, :object
	Scope.group(:object) << :object	
	Scope.before :session do
		Scope.group(:object).begin
		
	end				
	
	Scope.register :user, :session do
		Core::Model::AnonymousUser::ID
	end
	
	# Services
	services = Scope[::ActivePoint::Engine::Services]
	services[:security] = ::ActivePoint::Services::Security
	
	# Cache
	Cache.cached_with_params :class, Engine::APController.singleton_class, :check_plugin_enabled_for
end