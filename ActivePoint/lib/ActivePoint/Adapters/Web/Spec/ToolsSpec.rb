require 'WGUI/require'
require 'WGUIExt/require'
WGUI::Utils::TestServer

require "#{File.dirname(__FILE__)}/extension"
module WGUIExt				
	register_wiget "Menu" do		
		Tools::Menu.parent_get = lambda{|o| Object.new}
		Tools::Menu.each_child = lambda{|o, callback| [Object.new, Object.new].each &callback} 
		Tools::Menu.name_get = lambda{|o| "Name"}
		
		v = View.new
		a1 = v.add :a1, :string_edit
		
		root = v.add :root, :box
		root.add a1
		v.root = root
		
		l = View.new
		left = l.add :left, :wrapper, :component => Tools::Menu
		center = l.add :center, :wrapper, :component => :view
		
		root = l.add :layout, :border, :padding => true
		root.add :left, left
		root.add :center, center
		l.root = root
		
		Extension.bget_object = lambda{Object.new}
		Extension.bafter_object = lambda do
			Scope[Controller].view = v
			Scope[Window].layout = l
		end
		
		Spec::Adapter.new
	end		
	
	register_wiget "Breadcrumb" do
		v = View.new
		a1 = v.add :a1, :string_edit
		
		root = v.add :root, :box
		root.add a1
		v.root = root
		
		l = View.new
		top = l.add :top, :wrapper, :component => Tools::Breadcrumb
		center = l.add :center, :wrapper, :component => :view
		
		r = l.add :root, :border, :padding => true
		r.add :center, center
		r.add :top, top
		l.root = r
		
		Extension.bget_object = lambda{Object.new}
		Extension.bafter_object = lambda do
			Scope[Controller].view = v
			Scope[Window].layout = l
		end
		
		Spec::Adapter.new
	end		
	
	register_wiget "Messages" do
		v = View.new
		show = v.add :show, :button, :text => "Messages" 
		show.action = lambda do
			Scope[Tools::Messages].info "Info"
			Scope[Tools::Messages].warn "Info"
			Scope[Tools::Messages].error "Info"
		end
		
		clear = v.add :clear, :button, :text => "Clear"
		clear.action = lambda{Scope[Tools::Messages].clear}
		
		r = v.add :root, :flow
		r.add show
		r.add clear
		v.root = r
		
		l = View.new
		top = l.add :top, :wrapper, :component => Tools::Messages
		center = l.add :center, :wrapper, :component => :view
		
		r = l.add :root, :border, :padding => true
		r.add :center, center
		r.add :top, top
		l.root = r
		
		Extension.bget_object = lambda{Object.new}
		Extension.bafter_object = lambda do
			Scope[Controller].view = v
			Scope[Window].layout = l
		end
		
		Spec::Adapter.new
	end
	
	class LoginApp
		class << self
			attr_accessor :is_logged
		end
	end
	
	register_wiget "Login" do
		v = View.new
		a1 = v.add :a1, :string_edit
		
		r = v.add :root, :box, :title => "Properties", :border => true, :padding => true
		r.add a1
		v.root = r
		
		l = View.new
		left = l.add :left, :wrapper, :component => Tools::Login
		center = l.add :center, :wrapper, :component => :view
		
		r = l.add :layout, :border, :padding => true
		r.add :center, center
		r.add :left, left
		l.root = r
		
		Tools::Login.login = lambda do |name, password|
			raise Exception, "Invalid login!" unless name == "admin" and password == "admin"								
			LoginApp.is_logged = true
		end		
		Tools::Login.register = lambda{p "register_user"}
		Tools::Login.logout = lambda{LoginApp.is_logged = false}
		Tools::Login.logged = lambda{LoginApp.is_logged}					
		Tools::Login.user_name = lambda{"admin"}
		
		Extension.bget_object = lambda{Object.new}
		Extension.bafter_object = lambda do
			Scope[Controller].view = v
			Scope[Window].layout = l
		end
		
		Spec::Adapter.new
	end
	
	start_webserver
	join_webserver
end	