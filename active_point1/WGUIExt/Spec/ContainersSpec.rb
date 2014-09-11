require 'WGUI/require'
require 'WGUIExt/require'
WGUI::Utils::TestServer

#require "#{File.dirname(__FILE__)}/extension"

module WGUIExt		  
	register_wiget "Box And Flow Containers" do
		v = View.new
		
		a1 = v.add :a1, :string_edit
		a2 = v.add :a2, :string_edit
		
		attrs = v.add :attrs, :flow
		attrs.add a1
		attrs.add a2
		
		root = v.add :root, :box, :title => "Properties", :style => "float border_left border_top"
		root.add attrs
		root.add a1
		root.add a2
		
		v.root = root		
		v
	end
	
	register_wiget "Attributes Container" do
		v = View.new
		a1 = v.add :a1, :string_edit
		a2 = v.add :a2, :string_edit    
		
		attrs = v.add :attrs, :attributes, :title => "Group 1"
		attrs.add "Label", a1
		attrs.add nil, a2
		attrs.add "Label", [a1, a2]
		
		root = v.add :root, :box, :title => "Properties", :style => "float border"
		root.add attrs
		
		v.root = root
		v 
	end		
	
	register_wiget "View Continuation" do		
		main = View.new
		# Subflow
		sf = View.new
		sf.root = sf.add :sf, :box, :title => "Subflow"
		cancel = sf.add :cancel, :button, :text => "Cancel"
		cancel.action do
			main.cancel
		end				
		sf.root.add cancel
		
		# Main
		
		main.root = main.add :main, :box, :title => "Main"
		
		bsf = main.add :bsf, :button, :text => "Subflow"
		bsf.action do
			main.subflow sf
		end
		main.root.add bsf
		
		main
	end
	
	register_wiget "Weight" do
		v = View.new
		a1 = v.add :a1, :string_edit
		a2 = v.add :a2, :string_edit
		
		attrs = v.add :attrs, :attributes, :title => "Group 1"
		attrs.add "2", a2, 2
		attrs.add "1", a1, 1
		
		v.root = attrs		
		v
	end		
	
	register_wiget "View Inheritance" do		
		class ParentView < View
			build_view do |v|
				a1 = v.add :a1, :string_edit
				
				attrs = v.add :attrs, :attributes, :title => "Group 1"
				attrs.add "Parent", a1
				
				v.root = attrs	
			end
		end
		
		class ChildView < ParentView
			build_view do |v|
				a2 = v.add :a2, :string_edit
				
				attrs = v[:attrs]			
				attrs.add "Child", a2						
			end
		end
		
		ChildView.new
	end
	
	register_wiget "View Aspect" do
		class AspectParent < View
			build_view do |v|
				a1 = v.add :a1, :string_edit
				
				attrs = v.add :attrs, :attributes, :title => "Group 1"
				attrs.add "Parent", a1
				
				v.root = attrs	
			end
		end
		
		module AspectAspect
			inherit ViewAspect
			
			build_view do |v|
				aa = v.add :aa, :string_edit
				
				attrs = v[:attrs]			
				attrs.add "Aspect", aa						
			end
		end
		
		class AspectChild < AspectParent
			include AspectAspect
			
			build_view do |v|
				a2 = v.add :a2, :string_edit
				
				attrs = v[:attrs]			
				attrs.add "Child", a2						
			end
		end  	  	
		
		AspectChild.new
	end
	
	register_wiget "Composite View" do
		class ContainerView < View
			build_view do |v|
				box = v.add :box, :box, :style => "float border"
				v.root = box
				
				btn = v.add :btn, :button, :text => "Button"
				box.add btn
			end
		end
		
		class InnerView < View
			build_view do |v|
				text = v.add :text, :string_edit, :style => "float border"
				v.root = text
			end
		end
		
		iv = InnerView.new
		cv = ContainerView.new
		cv[:box].add iv
		
		cv
	end
	
	register_wiget "Tab Container" do
		v = View.new
		
		c1 = v.add :c1, :string_edit
		c2 = v.add :c2, :boolean_edit
		
		root = v.add :tab, :tab, :active => 'One', :title => "Title"
		root.add 'One', c1
		root.add 'Two', c2
		
		v.root = root
		v
	end
	
	register_wiget "TabJS Container" do
		v = View.new
		
		c1 = v.add :c1, :string_edit
		c2 = v.add :c2, :boolean_edit
		
		root = v.add :tab, :tabjs, :active => 'One'
		root.add 'One', c1
		root.add 'Two', c2
		
		v.root = root
		v
	end
	
	register_wiget "TabURL Container" do
		v = View.new
		
		c1 = v.add :c1, :string_edit
		c2 = v.add :c2, :boolean_edit
		
		root = v.add :tab, :taburl, :active => 'One'
		root.add 'One', c1
		root.add 'Two', c2
		
		v.root = root
		v
	end   
	
	register_wiget "Border" do    
		l = View.new
		
		left = l.add :left, :wrapper, :component => Utils::Stub
		right = l.add :right, :wrapper, :component => Utils::Stub
		top = l.add :top, :wrapper, :component => Utils::Stub
		bottom = l.add :bottom, :wrapper, :component => Utils::Stub
		center = l.add :center, :wrapper, :component => Utils::Stub
		
		root = l.add :layout, :border, :padding => true
		root.add :left, left
		root.add :right, right 
		root.add :top, top
		root.add :bottom, bottom
		root.add :center, center
		l.root = root
		
		l
	end
	
	
	class Extension	
		class << self		
			def view_state_get component_id		
				@state
			end
			
			def view_state_set component_id, state
				@state = state
			end
		end
	end
	
	register_wiget "Complex Containers should preserve their state during View update" do				
		v = View.new
		
		c1 = v.add :c1, :string_edit
		b_refresh = v.add :b_refresh, :button, :text => "Refresh", :action => lambda{build_view.call}
		
		root = v.add :tab, :tab, :active => 'One'
		root.add 'One', c1
		root.add 'Two', b_refresh
		
		v.root = root
		v
	end
	
	register_wiget "test" do
		WLabel.new "t"
	end
	
	start_webserver
	join_webserver
end	