require 'DomainModel/require'
#class TestObject
#	attr_accessor :a
#end
#
#
#module WebClient
#	
#	wigets = WebClient::H.wigets do
#		a Wigets::Editors::StringEdit	
#	end		
#	wigets[:r] = WButton.new "Read" do
#		Scope[Engine::ViewContext].wigets.values.every.respond_to :read, Scope[:object]
#	end	
#	wigets[:w] = WButton.new "Write", wigets[:a] do
#		Scope[Engine::ViewContext].wigets.values.every.respond_to :write, Scope[:object]
#	end
#	
#	view = WebClient::H.layout wigets do
#		container :box do						
#			a;
#			r;
#			w;
#		end	
#	end
#	
#	t = TestObject.new
#	t.a = "default"
#	WebClient::Extension.bget_object = lambda{t}
#	WebClient::Extension.bafter_object = lambda do 
#		Scope[Controller].view = view
#		Scope[ViewContext].wigets = wigets
#		
#	end
#end

WGUI::Engine::Runner.start WebClient::Engine::Window
WGUI::Engine::Runner.join