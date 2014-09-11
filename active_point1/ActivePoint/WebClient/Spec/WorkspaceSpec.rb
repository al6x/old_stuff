require 'WebClient/require'
WGUI::Utils::TestServer

require "#{File.dirname(__FILE__)}/extension"

module WebClient    				
	register_wiget "Workspace" do		
		raise "Obsoleted"
		class TestObject
			attr_accessor :path			
		end
		
		v = View.new
		path = v.add :path, :string_edit
		h.b :read, :button, "Read" do
			Scope[Engine::ViewContext].values = Scope[:object]
		end
		h.b :add, :button, "Add to Workspace" do
			o = Scope[:object]
			Scope[Engine::Workspace][Extension.get_path(o)] = Scope.custom_scope_get(:object)
		end				
		
		h.container :window, :box, {}, [
		:path,
		:read,
		:add
		]
		
		Extension.bafter_object = lambda do
			Scope[Controller].view = h.wigets[:window]
			Scope[Engine::ViewContext].wigets = h.wigets
		end
		
		a, b = TestObject.new, TestObject.new
		a.path, b.path = Path.new("a"), Path.new("b")
		
		objects = {a.path => a, b.path => b}
		Extension.bgo_to = lambda do |path|			
			Scope[Controller].object = objects[path] if objects.include? path
		end
		Extension.bget_path = lambda{|o| o.path}
		
		Spec::Adapter.new		
	end		
	
	start_webserver
	join_webserver
end