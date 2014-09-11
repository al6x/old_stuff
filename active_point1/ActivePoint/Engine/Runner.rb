module Runner
	PLUGIN_INITIALIZER_NAME = "Initializer"
	
	def run hash
		configure hash
		Object.const_set :R, Scope[:repository]
		check_and_initialize
		start_reloading if CONFIG[:reloading]
		_run			
	end
	
	protected
	def configure hash
		[:port, :directory].all?{|k| hash.include? k}.should! :be_true
		
		hash.each do |k, v|
			config = case k
				when :cache, :indexes then ObjectModel::CONFIG
				when :port, :directory, :default_object, :wgui_prefix, :web_services_prefix,
				:reloading, :initialize, :plugins, :before_run then CONFIG
			else
				should! :be_never_called
			end
			config[k] = v						
		end							
		
		CONFIG[:directory] = File.expand_path CONFIG[:directory]		
		File.create_directory CONFIG[:directory] unless File.exist? CONFIG[:directory]
	end
	
	def update_resource type, klass, resource
		if type == :class
			Cache.update :class			
			RubyExt::ClassLoader.reload_class klass.name
			Log.info "Class #{klass} has been reloaded!"
		elsif type == :resource
			Cache.update :class
			Log.info "Resource #{klass}['#{resource}'] has been reloaded!"
		end
	end
	
	def start_reloading
		RubyExt::Resource.add_observer self
		RubyExt::Resource.start_watching
	end
	
	def check_and_initialize
		WebClient.init
		
		unless R.storage.get("ActivePoint Initialized") == "true"						
			# WebClient
			WebClient.initialize_database
			
			# Custom Initialization
			CONFIG[:initialize].should!(:be_a, Proc).call
			
			R.storage.put "ActivePoint Initialized", "true"
		end				
		
		initialized_plugins = Set.new
		CORE_PLUGINS.each do |plugin_klass|						
			Runner.check_and_initialize_plugin plugin_klass, initialized_plugins
			initialized_plugins << plugin_klass
		end		
		
		CONFIG[:plugins].should!(:be_a, Array).each do |plugin_klass|
			Runner.check_and_initialize_plugin plugin_klass, initialized_plugins
			initialized_plugins << plugin_klass
		end
		
		CONFIG[:before_run].should!(:be_a, Proc).call				
	end
	
	def _run							
		# WebServer Run
		app = Rack::URLMap.new \
			"/" => lambda{|env| redirect_to_default_object env},
		CONFIG[:wgui_prefix] => WGUI::Engine::BrigeServlet.new(WebClient::Client, CONFIG[:wgui_prefix], "object"),
		CONFIG[:web_services_prefix] => lambda{|env| ws_stub env}
		
		#		app = Rack::Lint.new app if $debug
		
		app = Rack::Handler::Mongrel.new app
		server = Mongrel::HttpServer.new('0.0.0.0', CONFIG[:port].should_not!(:be_nil))
		server.register('/', app)
		
		@webserver = server.run		
		@webserver.join
	end
	
	def redirect_to_default_object env
		[301, {"location" => "#{CONFIG[:wgui_prefix]}/#{CONFIG[:default_object]}", "Content-Type" => "text/html"}, []]
	end
	
	def ws_stub env
		[200, {"Content-Type" => "text/plain",}, ["Web Services Will Be Here"]]
	end
	
	class << self
		def check_and_initialize_plugin plugin_class, initialized_plugins
			plugin_class.class.should! :be_in, [Class, Module]
			initializer_class = begin
				eval "#{plugin_class}::#{PLUGIN_INITIALIZER_NAME}", TOPLEVEL_BINDING, __FILE__, __LINE__				
			rescue NameError => e
				raise e unless e.class == NameError
				nil
			end			
			
			return unless initializer_class
			
			initializer = initializer_class.new
			if initializer.respond_to :depends_on
				missed_dependencies = initializer.depends_on.to_set - initialized_plugins
				raise "Plugin '#{plugin_class}' has missed dependencies #{missed_dependencies.to_a}!" unless missed_dependencies.empty?
			end
			initializer.respond_to :check_and_initialize			
		end
	end
end