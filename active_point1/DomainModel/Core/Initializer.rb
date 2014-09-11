class Initializer	
	def initialize_storage storage
		MicroContainer::ScopeManager.activate_thread :initializer do     
			Transactional.transaction{
				run storage
			}
			Transactional.commit
		end    		
	end
	
	protected
	def run storage
		croot = storage.root.copy
		
		# Core		
		croot.core = core = Core::Core.new.set(:name => "Core")
		
		# Users
		core.users = Core::Users.new.set(:name => "Users")
		
		# Groups
		core.groups = Core::Groups.new.set(:name => "Groups")				
		
		# Tools		
		core.tools = tools = Core::Tools.new.set(:name => "Tools")
		
		tools.tools << tobject_view = Tools::ObjectView.new.set(:name => "ObjectView")
		tools.tools << tbreadcrumb = Tools::Breadcrumb.new.set(:name => "Breadcrumb")
		tools.tools << tlogo = Tools::Logo.new.set(:name => "Logo")	
		tools.tools << tmenu = Tools::Menu.new.set(:name => "Menu")	
		tools.tools << tmessages = Tools::Messages.new.set(:name => "Messages")	
		tools.tools << tlogin = Tools::Login.new.set(:name => "Login")
		
		# Layouts		
		core.layouts = layouts = Core::Layouts.new.set(:name => "Layouts")
		
		layouts.layouts << lborder = Layouts::Border.new.set(:name => "Core Layout")
		
		lborder.left_tools << tlogo
		lborder.left_tools << tmenu
		lborder.left_tools << tlogin
#		lborder.top_tools << tmessages
		lborder.center_tools << tobject_view
		lborder.top_tools << tbreadcrumb		
				
		
		# Root Layout
		croot.layout = lborder
	end
end