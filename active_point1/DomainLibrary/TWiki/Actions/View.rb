class View < DomainModel::Actions::Action
	def build_dmeta
		# View
		h = H.new
		h.e :name, :string_view
		h.e :text, :richtext_view
		h.e :children, :table_view, {
			:head => ["Name"],
			:values => [:name],
			:types => [:string_view]
		}
		
		h.b :edit, :button, "Edit" do
			Scope[:controller].execute :edit
		end
		h.b :add, :button, "Add" do
			Scope[:controller].execute :add
		end
		h.b :delete, :button, "Delete", {:inputs => :children} do
			selected = @wigets[:children].checkboxes
			Scope[:controller].execute :delete, {:selected => selected}
		end
		
		h.container :toolbar, :flow, {:floating => true, :padding => true, :highlithed => true}, [:edit]
		h.container :table_toolbar, :flow, {:floating => true, :padding => true, :highlithed => true}, [:add, :delete]
		
		h.container :children_container, :box, {:title => "Children", :border => true, :padding => true}, [
		:table_toolbar,
		:children
		]
		h.container :view, :box, {:padding => true}, [
		:name,
		:toolbar,
		:text,
		:children_container
		]		
		@wigets = h.wigets
		
		# Layout
		h = H.new
				
		h.container :menu, :wrapper, :component => WebClient::Tools::Menu
		h.container :login, :wrapper, :component => WebClient::Tools::Login
		
		h.container :left, :box, {:padding => true}, [
		:menu, 
		:login
		]
		h.container :top, :wrapper, :component => WebClient::Tools::Breadcrumb
		h.container :center, :wrapper, :component => :view
		
		h.container :view, :border, {:padding => true}, {
			:left => :left, 
			:top => :top, 
			:center => :center		
		}
		
		@layout = h.wigets
	end
	
	def execute
		controller.view = @wigets[:view]
		view_context.wigets = @wigets
		view_context.wigets.values.every.respond_to :read, object						
		
		window.layout = @layout[:view]
	end
end