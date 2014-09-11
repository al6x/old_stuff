require 'WGUI/require'
require 'WGUIExt/require'
require 'ObjectModel/require'
WGUI::Utils::TestServer

module WGUIExt
	dir = File.dirname __FILE__
	ObjectModel::CONFIG[:directory] = "#{dir}/data"
	ObjectModel::Repository.delete :test
	STORAGE = ObjectModel::Repository.new(:test)	
	
	class Extension	
		class << self					
			def get_data_storage
				STORAGE
			end
		end
	end
	
	class Controller < WComponent		
		children :view		
		
		attr_reader :view
		def view= view
			@view = view
			refresh
		end
	end
	
	register_wiget "Base Types" do		
		class TestObject
			include OpenConstructor
			attr_accessor :string, :number, :boolean, :text, :date
		end
		
		to = TestObject.new.set :string => "string", :number => 100, :boolean => true, 
		:text => "Line 1\nLine 2", :date => Date.new(2000, 1, 1)
		
		controller = Controller.new
		
		build_edit = nil
		build_view = lambda do
			v = View.new
			
			string = v.add :string, :string_view
			text = v.add :text, :text_view
			number = v.add :number, :number_view
			boolean = v.add :boolean, :boolean_view
			date = v.add :date, :date_view
			
			bedit = v.add :bedit, :button, :text => "Edit"
			bedit.action{build_edit.call}
			
			root = v.add :root, :attributes, :title => "Group 1"
			root.add nil, bedit
			root.add ":string", string
			root.add ":text", text
			root.add ":number", number
			root.add ":boolean", boolean						
			root.add ":date", date									
			v.root = root			
			
			v.values = to
			controller.view = v
		end
		
		build_edit = lambda do
			v = View.new			
			string = v.add :string, :string_edit
			text = v.add :text, :text_edit
			number = v.add :number, :number_edit
			boolean = v.add :boolean, :boolean_edit
			date = v.add :date, :date_edit
			
			root = v.add :root, :attributes
			btn = v.add :btn, :button, :text => "View"
			btn.action root do
				to.set v.values 
				build_view.call
			end
			
			root.add nil, btn
			root.add ":string", string
			root.add ":text", text
			root.add ":number", number
			root.add ":boolean", boolean						
			root.add ":date", date			
			v.root = root
			
			v.values = to
			controller.view = v
		end		
		
		build_view.call
		controller
	end
	
	register_wiget "Select" do
		class TestObject
			include OpenConstructor
			attr_accessor :select, :multiselect, :search_select, :search_multiselect
		end
		
		to = TestObject.new.set :select => "initial value", :multiselect => ["b", "d", "Invalid!"],
		:search_select => "5", :search_multiselect => ["5", "10", "Invalid!"]
		
		controller = Controller.new
		
		build_edit = nil
		build_view = lambda do
			v = View.new
			select = v.add :select, :string_view
			multiselect = v.add :multiselect, :list_view
			search_select = v.add :search_select, :string_view
			search_multiselect = v.add :search_multiselect, :list_view
			
			edit = v.add :edit, :button, :text => "Edit"
			edit.action{build_edit.call}
			
			root = v.add :root, :attributes
			root.add nil, edit
			root.add ":select", select
			root.add ":multiselect", multiselect
			root.add ":search_select", search_select
			root.add ":search_multiselect", search_multiselect
			v.root = root
			
			v.values = to
			controller.view = v
		end
		
		build_edit = lambda do
			v = View.new
			select = v.add :select, :select, :values => ["a", "b"]
			
			multiselect = v.add :multiselect, :select, 
			:values => ["a", "b", "c", "d"], :multiple => true
			
			ssvalues = []; 21.times{|i| ssvalues << i.to_s}
			
			search_select = v.add :search_select, :select, :values => ssvalues
			
			search_multiselect = v.add :search_multiselect, :select, 
			:multiple => true, :values => ssvalues
			
			root = v.add :root, :attributes
			
			bview = v.add :bview, :button, :text => "View"
			bview.action root do
				to.set v.values 
				build_view.call
			end									
			
			root.add nil, bview
			root.add ":select", select
			root.add ":multiselect", multiselect
			root.add ":search_select", search_select
			root.add ":search_multiselect", search_multiselect
			v.root = root		
			
			v.values = to
			controller.view = v
		end						
		
		build_view.call		
		controller
	end					
	
	register_wiget "Reference" do
		#		v = View.new
		#		
		#		reference = v.add :reference, :reference
		#		v.root = reference
		#		
		#		class TestObject
		#			include OpenConstructor
		#			attr_accessor :reference
		#		end
		#		
		#		t = TestObject.new
		#		t.set :reference => t
		#		Extension.bget_object = lambda{t}
		#		
		#		Editors::Reference.name_get = lambda{"Object name"}
		#		
		#		Extension.bafter_object = lambda do
		#			Scope[Controller].view = v
		#			Scope[:view].values = Scope[:object]
		#		end				
		#		
		#		Spec::Adapter.new
	end		
	
	register_wiget "File And Image" do
		class TestObject
			include OpenConstructor
			attr_accessor :file, :image
		end
		
		to = TestObject.new		
		controller = Controller.new
		
		build_edit = nil
		build_view = lambda do
			v = View.new			
			file = v.add :file, :file_view
			image = v.add :image, :image_view
			
			edit = v.add :edit, :button, :text => "Edit"
			edit.action{build_edit.call}
			
			root = v.add :root, :attributes
			root.add nil, edit
			root.add ":file", file
			root.add ":image", image
			v.root = root
			
			controller.view = v
			v.values = to
		end
		
		build_edit = lambda do
			v = View.new
			file = v.add :file, :file_edit
			image = v.add :image, :file_edit
			
			root = v.add :root, :attributes
			
			bview = v.add :bview, :button, :text => "View"
			bview.action root do
				to.set v.values 
				build_view.call
			end									
			
			root.add nil, bview
			root.add ":file", file
			root.add ":image", image
			v.root = root
			
			controller.view = v
			v.values = to
		end		
		
		build_view.call
		controller
	end
	
	register_wiget "RichText" do
		class TestObject
			include OpenConstructor
			attr_accessor :rich_text
		end
		
		to = TestObject.new.set :rich_text => Editors::RichTextData.new
		controller = Controller.new
		
		build_edit = nil
		build_view = lambda do
			v = View.new			
			rich_text = v.add :rich_text, :richtext_view
			
			edit = v.add :edit, :button, :text => "Edit"
			edit.action{build_edit.call}
			
			root = v.add :root, :attributes
			root.add nil, edit
			root.add ":rich_text", rich_text
			v.root = root
			
			v.values = to
			controller.view = v			
		end
		
		build_edit = lambda do
			v = View.new			
			rich_text = v.add :rich_text, :richtext_edit
			
			root = v.add :root, :attributes
			
			bview = v.add :bview, :button, :text => "View"
			bview.action root do
				to.set v.values 
				build_view.call
			end									
			
			root.add nil, bview
			root.add ":rich_text", rich_text
			v.root = root	
			
			v.values = to
			controller.view = v			
		end		
		
		build_view.call
		controller
	end		
	
	start_webserver WGUI::Utils::TestServer, "object"
	join_webserver
end	