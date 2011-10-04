module C
	class << self
		extend Injectable
		inject :app_controller => ActivePoint::Adapters::Web::AppController,	:controller => :controller
		
		def object= object
			app_controller.object = object
		end
		
		def object
			app_controller.object
		end			
		
		def user
			R.by_id Scope[:user]
		end		
		
		def can? permission, object = self.object
			services[:security].can? user, permission, object
		end
		
		def owner? object = C.object, user = C.user
			owner = object.respond_to :object_owner
			return owner == user
		end
		
		def class
				controller.class
			end
			
			def controller_for object		
				ActivePoint::Engine::Extensions.controller_for object, ActivePoint::Adapters::Web::UI_NAME
			end
			
			def editor_for object		
				controller_class = controller_for object
				controller_class.editor.new
			end
			
			def services
				Scope[:services]
			end
			
			def messages
				Scope["Messages"]
			end
			
			def app
				Scope[ActivePoint::Adapters::Web::App]
			end
		end
		
		module Model; end
		module UI; end
		
		Model::Skinnable = ActivePoint::Plugins::Appearance::Model::Skinnable
		UI::Skinnable = ActivePoint::Plugins::Appearance::UI::Skinnable
		UI::ShowSkinnable = ActivePoint::Plugins::Appearance::UI::Skinnable::ShowSkinnable
		
		Model::Layout = ActivePoint::Plugins::Appearance::Model::Layout
		UI::Layout = ActivePoint::Plugins::Appearance::UI::Layout
		UI::ShowLayout = ActivePoint::Plugins::Appearance::UI::Layout::ShowLayout
		
		Model::Secure = ActivePoint::Plugins::Security::Model::Secure
		UI::Secure = ActivePoint::Plugins::Security::UI::Secure
		UI::ShowSecure = ActivePoint::Plugins::Security::UI::Secure::ShowSecure
		
		Model::User = ActivePoint::Plugins::Users::Model::User
		Model::Group = ActivePoint::Plugins::Users::Model::Group
		
		Model::Policy = ActivePoint::Plugins::Security::Model::Policy
		
		Model::Wiget = ActivePoint::Plugins::Appearance::Model::Wiget
	end