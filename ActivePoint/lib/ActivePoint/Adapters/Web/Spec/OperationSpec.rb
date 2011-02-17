require 'Adapters::Web/require'
WGUI::Utils::TestServer

require "#{File.dirname(__FILE__)}/extension"

module Adapters::Web						
	View = Wigets::View
	
	register_wiget "Simple Operation" do		
		class TestObject
			attr_accessor :value
		end
		
		class EditStringOperation
			attr_accessor :on[:ok], :on[:cancel]
			
			def run
				v = View.new
				value = v.add :value, :string_edit
				
				ok = v.add :ok, :button, :text => "Ok"
				ok.action = lambda do
					Scope[:object].set Scope[:view].values 
					on[:ok].call	
				end
				ok.inputs = value
				
				cancel = v.add :cancel, :button, :text => "Cancel", :action => lambda{on[:cancel].call}
				
				root = v.add :root, :box, :padding => true
				root.add value
				root.add ok
				root.add cancel
				v.root = root								
				
				Scope[Controller].view = v
				Scope[:view].values = Scope[:object]				
			end
		end			
		
		build_view = nil
		v = View.new
		value = v.add :value, :string_view
		button = v.add :button, :button, :text => "Edit" 
		button.action = lambda do					
			op = EditStringOperation.new					
			op.on[:ok] = build_view
			
			back = Scope.custom_scope_get :view
			op.on[:cancel] = lambda do
				Scope.custom_scope_set :view, back
				Scope[:view].refresh					
			end
			
			op.run
		end
		
		root = v.add :root, :attributes
		root.add nil, button
		root.add ":value", value
		v.root = root 
		
		build_view = lambda do
			Scope[Controller].view = v			
			Scope[:view].values = Scope[:object]
		end
		
		to = TestObject.new			
		to.value = "initial value"		
		
		Extension.set :bget_object => lambda{|path| to}, :bafter_object => build_view
		
		Spec::Adapter.new
	end
	
	register_wiget "Exclusive Mode" do
		v = View.new
		ex = v.add :ex, :button, :text => "Go to Exclusive", :action => lambda{Scope[Window].exclusive = true}
		
		nex = v.add :nex, :button, :text => "Go to Non Exclusive", :action => lambda{Scope[Window].exclusive = false}
		
		root = v.add :root, :box
		root.add ex
		root.add nex
		v.root = root
		
		l = View.new
		ttool = l.add :ttool, :wrapper, :component => Tools::Stub
		center = l.add :center, :wrapper, :component => :view
		
		root = l.add :root, :box
		root.add center
		root.add ttool
		l.root = root
		
		Extension.bafter_object = lambda do
			Scope[Window].layout = l
			Scope[Controller].view = v
		end
		
		Spec::Adapter.new
	end	
	
	register_wiget "Read And Write Attributes" do
		class TestObject
			attr_accessor :a
		end
		
		v = View.new
		a = v.add :a, :string_edit
		
		r = v.add :r, :button, :text => "Read" 
		r.action = lambda{Scope[:view].values = Scope[:object]}
		
		w = v.add :w, :button, :text => "Write"
		w.action = lambda{Scope[:object].set Scope[:view].values}
		w.inputs = a
		
		root = v.add :root, :box
		root.add a
		root.add r
		root.add w
		v.root = root
		
		t = TestObject.new
		t.a = "default"
		Extension.bget_object = lambda{t}
		Extension.bafter_object = lambda do 
			Scope[Controller].view = v
		end
		
		Spec::Adapter.new
	end
	
	register_wiget "Custom Control Element" do
		
	end
	
	start_webserver
	join_webserver
end	