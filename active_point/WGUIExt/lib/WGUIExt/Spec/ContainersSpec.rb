require 'WGUI/require'
require 'WGUIExt/require'
WGUI::Utils::TestServer

#require "#{File.dirname(__FILE__)}/extension"
MicroContainer::Scope.before :session do
	MicroContainer::Scope[WGUI::Engine::Window].css_list = ["#{WGUIExt::DEFAULT_STYLE}/style.css"]
end

module WGUIExt		  	
	register_wiget "Form" do		
		class FormDSLSpec < WComponent
			inherit Form
			
			build :box, :title => "Box", :css => "padding" do
				line :title => "Line", :css => "padding" do
					box :css => "padding" do
						string_view :value => "Hello"
					end
				end
				
				attributes :title => "User" do
					add "ID", :string_edit
					add "Name", :string_edit, :attr => :name
					add "Group", [
					new(:string_view, :attr => :group),
					new(:button, :text => "Edit"), 
					new(:button, :text => "Delete")
					]
				end
				
				line :wide => false do
					button :text => "Ok"
					button :text => "Cancel"
				end
			end						
		end
		FormDSLSpec.new.set! :object => {:name => "Name", :group => "Group"}
	end
	
	register_wiget "CommonForm" do				
		Form.common_form :box do
			string_view :value => "Hello"
		end
	end
	
	register_wiget "Box And Line Containers" do
		class BoxAndLine < WComponent
			inherit Form
			
			build :box, :title => "Properties" do
				string_edit
				string_edit
				line do
					string_edit
					string_edit
				end								
			end
		end
		BoxAndLine.new
		
	end
	
	register_wiget "Attributes Container" do
		class AttributesSpec < WComponent
			inherit Form
			
			build :attributes, :title => "Group" do
				add "Label", :string_edit
				add nil, :string_edit
				add "Label", [new(:string_edit), new(:button, :text => "Ok")]
			end			
		end
		AttributesSpec.new
	end		
	
	register_wiget "View Continuation" do		
		raise "outdated"		
		#		main = View.new
		#		# Subflow
		#		sf = View.new
		#		sf.root = sf.add :sf, :box, :title => "Subflow"
		#		cancel = sf.add :cancel, :button, :text => "Cancel"
		#		cancel.action do
		#			main.cancel
		#		end				
		#		sf.root.add cancel
		#		
		#		# Main
		#		
		#		main.root = main.add :main, :box, :title => "Main"
		#		
		#		bsf = main.add :bsf, :button, :text => "Subflow"
		#		bsf.action do
		#			main.subflow sf
		#		end
		#		main.root.add bsf
		#		
		#		main
	end
	
	register_wiget "Weight" do
		raise "outdated"
		#		v = View.new
		#		a1 = v.add :a1, :string_edit
		#		a2 = v.add :a2, :string_edit
		#		
		#		attrs = v.add :attrs, :attributes, :title => "Group 1"
		#		attrs.add "2", a2, 2
		#		attrs.add "1", a1, 1
		#		
		#		v.root = attrs		
		#		v
	end		
	
	register_wiget "View Inheritance" do		
		raise "Outdated"
		#		class ParentView < WComponent
		#			inherit Form
		#			
		#			build_view do
		#				a1 = v.add :a1, :string_edit
		#				
		#				attrs = v.add :attrs, :attributes, :title => "Group 1"
		#				attrs.add "Parent", a1
		#				
		#				v.root = attrs	
		#			end
		#		end
		#		
		#		class ChildView < WComponent
		#			inherit Form
		#			
		#			build do |v|
		#				a2 = v.add :a2, :string_edit
		#				
		#				attrs = v[:attrs]			
		#				attrs.add "Child", a2						
		#			end
		#		end
		#		
		#		ChildView.new
	end
	
	register_wiget "View Aspect" do
		raise "outdated"
		#		class AspectParent < View
		#			build_view do |v|
		#				a1 = v.add :a1, :string_edit
		#				
		#				attrs = v.add :attrs, :attributes, :title => "Group 1"
		#				attrs.add "Parent", a1
		#				
		#				v.root = attrs	
		#			end
		#		end
		#		
		#		module AspectAspect
		#			inherit ViewAspect
		#			
		#			build_view do |v|
		#				aa = v.add :aa, :string_edit
		#				
		#				attrs = v[:attrs]			
		#				attrs.add "Aspect", aa						
		#			end
		#		end
		#		
		#		class AspectChild < AspectParent
		#			include AspectAspect
		#			
		#			build_view do |v|
		#				a2 = v.add :a2, :string_edit
		#				
		#				attrs = v[:attrs]			
		#				attrs.add "Child", a2						
		#			end
		#		end  	  	
		#		
		#		AspectChild.new
	end
	
	register_wiget "Composite View" do
		class InnerView < WComponent
			inherit Form
			
			build :box, :css => "border padding" do
				string_edit
			end
		end
		
		class ContainerView < WComponent
			inherit Form
			
			build :box, :css => "border padding" do
				add InnerView.new
				button :text => "Button"
			end
		end
		
		ContainerView.new
	end
	
	register_wiget "Tab Container" do
		class TabContainer < WComponent
			inherit Form
			
			build :tab, :active => "One", :title => "Title" do
				add "One", new(:string_edit)
				add "Two", :box, :title => "Title" do
					button :text => "Ok"
				end
				add "Three", :string_edit
			end
		end
		TabContainer.new
	end	
	
	register_wiget "Tab should hide Tabs if there is only one" do
		class OneTabContainer < WComponent
			inherit Form
			
			build :box do
				tab :active => "One", :title => "Tab" do
					add "One", new(:string_edit)
				end
				tab_js :active => "One", :title => "Tab JS" do
					add "One", new(:string_edit)
				end
			end
		end
		OneTabContainer.new
	end
	
	register_wiget "TabJS Container" do
		class TabContainer < WComponent
			inherit Form
			
			build :tab_js, :active => "One", :title => "Title" do
				add "One", new(:string_edit)
				add "Two", :box do
					button :text => "Ok"
				end
			end
		end
		TabContainer.new
	end
	
	register_wiget "TabURL Container" do
		raise "outdated"
		#		v = View.new
		#		
		#		c1 = v.add :c1, :string_edit
		#		c2 = v.add :c2, :boolean_edit
		#		
		#		root = v.add :tab, :taburl, :active => 'One'
		#		root.add 'One', c1
		#		root.add 'Two', c2
		#		
		#		v.root = root
		#		v
	end   
	
	register_wiget "Border" do  
		class BorderContainer < WComponent
			inherit Form
			
			build :border do
				center :box do
					string_view :value => "Center"
				end
				left :string_view, :value => "Left"
				top :string_view, :value => "Top"
				right :string_view, :value => "Right"
				bottom :string_view, :value => "Bottom"
			end
		end
		BorderContainer.new
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
		class ComplexContainer < WComponent
			inherit Form
			
			build :tab, :component_id => "tab", :active => "One" do
				add "One", :string_view
				add "Two", :button, :text => "Refresh", :action => lambda{form.refresh}
			end
		end
		ComplexContainer.new
		
		#		v = View.new
		#		
		#		c1 = v.add :c1, :string_edit
		#		b_refresh = v.add :b_refresh, :button, :text => "Refresh", :action => lambda{build_view.call}
		#		
		#		root = v.add :tab, :tab, :active => 'One'
		#		root.add 'One', c1
		#		root.add 'Two', b_refresh
		#		
		#		v.root = root
		#		v
	end
	
	register_wiget "Table" do
		#		class TestObject
		#			include OpenConstructor
		#			attr_accessor :table
		#		end
		#		
		#		class RowObject
		#			include OpenConstructor
		#			attr_accessor :string, :text
		#		end
		#		
		#		to = TestObject.new	
		#		to.table = [
		#		RowObject.new.set(:string => "StringA", :text => "TextA\nLine1\nLine2"),
		#		RowObject.new.set(:string => "StringB", :text => "TextB\nLine1\nLine2")
		#		]		
		#		controller = Controller.new
		#		
		#		build_view = lambda do			
		#			v = View.new
		#			string_view = lambda do |o| 
		#				e = Editors::StringView.new
		#				e.value = o.string
		#				e
		#			end
		#			text_view = lambda do |o| 
		#				e = Editors::TextView.new
		#				e.value = o.text
		#				e
		#			end
		#			table = v.add :table, :table, :head => ["String", "Text"], :editors => [string_view, text_view]
		#			
		#			root = v.add :root, :attributes
		#			root.add ":tablel", table
		#			v.root = root
		#			
		#			controller.view = v
		#			v.values = to
		#		end
		#		
		#		build_view.call
		#		controller
		
		class TableContainer < WComponent
			inherit Form
			
			build :box do 
				table :attr => :table do
					head do
						object[0].keys.sort.each do |name|
							string_view :value => name
						end
					end
					body do
						object.keys.sort.each do |name|
							string_view :value => object[name]
						end
					end
				end
			end
		end		
		
		data = {
			:table => [
			{:name => "Name1", :value => "Value1"},
			{:name => "Name2", :value => "Value2"},
			]
		}
		
		TableContainer.new.set :object => data
	end		
	
	start_webserver
	join_webserver
end	