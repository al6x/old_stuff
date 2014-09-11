class WCController
	include Log
	extend Managed
	scope :session
	inject :client => Client, :window => WGUI::Engine::Window, :user => :user
		
	def after_object_set object
		set_layout object
		set_skin object
		client.refresh
	end
	
	def login						
		form = Login.new
		form.on_ok = lambda do	
			name, password = form.values[:name], form.values[:password]
			unless C.services[:security].login name, password
				raise UserError, "User with such Name and Password not found!"
			end			
			client.exclusive = nil
		end
		form.on_cancel = lambda{client.exclusive = nil}		
		client.exclusive = form
	end
	
	def logout
		C.services[:security].logout
	end
	
	protected
	def set_layout o		
		l_def = o.up :wc_layout
		return if @previous_layout == l_def
		@previous_layout = l_def
		
		if l_def
			client.layout = l_def.build_layout
		else
			client.layout = nil
		end				
	end
	
	def set_skin o				
		skin = o.up :wc_skin
		if skin and !skin.empty?
			client.skin = skin		
			window.favicon = "#{skin}/favicon"			
			window.css_list = [WGUIExt::DEFAULT_CSS, "skins/#{skin}/style.css"]
		else
			client.skin = ""
			window.favicon = nil
			window.css_list = [WGUIExt::DEFAULT_CSS]
		end
	end	
end