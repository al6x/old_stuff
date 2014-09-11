class UserMenu < WComponent
	extend Managed
	scope :user
	inject :app_controller => AppController	
	
	children :@login, :@logout, :@contact_us, :@languages
	
	def build
		if C.user.anonymous?
			@login = new :link_button, :text => `Login`, :action => lambda{app_controller.login}
			@logout = nil
		else
			@login = nil
			logout = lambda{C.app_controller.logout C.user.name}
			@logout = new :link_button, :text => `Logout`, :action => logout			
		end
		@contact_us = new :link_button, :text => `Contact Us`, 
		:action => lambda{C.services[:contact_us].contact_us}
		
		service = C.services[:localization]
		if service.languages.size > 1
			@languages = WSelectButton.new
			service.languages.each do |key, name|
				@languages.on name do
					service.language = key
				end
			end
			@languages.selected = service.languages[service.language]
		else
			@languages = nil
		end
	end
	
	def user_name
		C.user.anonymous? ?	to_l(C.user.name) : C.user.name
	end
end