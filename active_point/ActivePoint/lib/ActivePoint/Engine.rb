class Engine	
	class << self
		def activate hash = {}
			@initialized = false
			
			parse_configuration hash									
			start_reloading if CONFIG[:reloading]
			Scope.register :services, :application do
				Engine::Services.new
			end
			
			was_initialized = activate_engine_and_extensions				
			Scope[:services][:webserver].activate # Hack
			
			reset_data! if CONFIG[:reset_data] and was_initialized
			
			CONFIG[:after_start].should!(:be_a, Proc).call									
			ActivePoint.log.info "Initialization finished."												
		end
		
		def join
			Scope[:services][:webserver].join
		end				
		
		def reset_data!
			File.exist?(CONFIG[:directory]).should! :be_true
			
			# Clear
			Extensions.teardown!
			Extensions.clear_data!
			R.close
			::ObjectModel::Repository.delete :repository, "#{CONFIG[:directory]}/#{OBJECT_MODEL_NAME}"	
			
			# Create
			Object.const_set :R, create_repository			
			Extensions.initialize_data!
			Extensions.restart!			
			ActivePoint.log.info "Data has been Reset!"
		end
		
		protected	
		def activate_engine_and_extensions
			initialize_directory
			Extensions.activate!
			
			Object.const_set :R, create_repository
			was_initialized = Extensions.any_initialized?
			
			# Extensions activation									
			Extensions.initialize_data!
			Extensions.startup!			
			
			return was_initialized
		end		
		
		def parse_configuration hash			
			#						hash.each do |k, v|
			#							config = case k
			#								when :cache, :indexes then ObjectModel::CONFIG
			#							else
			#								CONFIG
			#							end
			#							config[k] = v						
			#						end						
			
			default = ActivePoint["config.rb"]
			default.keys.to_set.should! :superset?, hash.keys.to_set
			
			if File.exist?("config/active_point.rb") 
				user_conf = eval File.read("config/active_point.rb"), TOPLEVEL_BINDING, __FILE__, __LINE__
				user_conf.should! :be_a, Hash
			else
				user_conf = {}
			end
			ActivePoint.const_set :CONFIG, RubyExt::Config.new(hash, user_conf, default)
			
			CONFIG.should! :include, :directory
			CONFIG[:directory] = File.expand_path CONFIG[:directory]
		end
		
		def initialize_directory									
			File.create_directory CONFIG[:directory]
		end
		
		def create_repository
			dir = "#{CONFIG[:directory]}/#{OBJECT_MODEL_NAME}"
			File.create_directory dir unless File.exist? dir		
			
			r = ::ObjectModel::Repository.new :repository, \
			:transaction_strategy => ActivePoint::TransactionStrategy,
			:directory => dir
			r.entity_listeners << ::ActivePoint::Engine::OMExtension::Listener.new
			r
		end
		
		def update_resource type, klass, resource		
			if type == :class						
				Cache.update :class			
				RubyExt::ClassLoader.reload_class klass.name
				Log.info "Class #{klass} has been reloaded!"
			elsif type == :resource
				Cache.update :class
				WGUI::Utils::TemplateHelper.cache.clear
				Log.info "Resource #{klass}['#{resource}'] has been reloaded!"
			end
		end
		
		def start_reloading
			RubyExt::Resource.add_observer self
			RubyExt::FileSystemProvider.start_watching
		end
	end
end