class AppController
	include Log
	extend Managed
	scope :session
	inject :app => App, :window => WGUI::Engine::Window, :user => :user, :controller => :controller,
	:workspace => App::Workspace
	
	def object= object		
		object.should! :be_a, Entity
		return if Scope[:object] == object.entity_id
		
#		APController.check_plugin_enabled_for object.class
		
		if workspace.include? object
			workspace.restore_scopes_for object
		else
			Scope.group(:object).begin
			Scope[:object] = object.entity_id
		end						
		
		set_layout object
		set_skin object
		app.refresh
	end  		
	
	def object
		entity_id = Scope[:object]
		entity_id ? R.by_id(entity_id) : nil
	end		
	
	def logout name
		C.user.should_not! :anonymous?
		
		restore = C.object
		Scope.begin :user
		Scope[:user] = Plugins::Users::Model::User::ANONYMOUS
		Scope.group(:object).begin
		
		C.object = restore
	end	
	
	def login						
		form = Login.new
		form.on[:ok] = lambda do				
			_login form.name, form.password
			C.app.exclusive = nil
		end
		
		form.on[:cancel] = lambda{C.app.exclusive = nil}		
		C.app.exclusive = form
	end
	
	def _create_controller
		return NilController.new if object == nil		
		
		controller_class = Engine::Extensions.controller_for object.class, Adapters::Web::UI_NAME
		controller_class.should! :be, Controller				
		controller = controller_class.new
		controller.should! :respond_to?, :show				
		
		sw = Adapters::Web::Controller::SecureWrapper.new controller
		sw.show
		
		return sw
	end			
	
	protected
	def _login name, password
		C.user.should! :anonymous?
		
		user = C.services[:security].user_for name, password
		
		restore = C.object
		Scope.begin :user
		Scope[:user] = user.entity_id
		Scope.group(:object).begin
		
		C.object = restore				
	end
	
	def set_layout o		
		l_def = o.up :wc_layout
		unless @previous_layout == l_def
			@previous_layout = l_def
			
			if l_def
				app.layout = l_def.build_layout
			else
				app.layout = nil
			end				
		end
	end
	
	def set_skin o			
		skinned = o.search_up do |o| 
			s = o.respond_to :wc_skin
			s and !s.empty?
		end
		skin = skinned ? skinned.wc_skin : ""
		unless skin.empty?
			app.skin = skin		
			window.favicon = "#{SKINS}/#{skin}/favicon"			
			window.css_list = ["#{WGUIExt::DEFAULT_STYLE}/style.css", "#{SKINS}/#{skin}/style.css"]
		else
			app.skin = ""
			window.favicon = nil
			window.css_list = ["#{WGUIExt::DEFAULT_STYLE}/style.css"]
		end
	end				
	
	class NilController
		def view
			WLabel.new to_l("Object not specified!")			
		end
	end
end