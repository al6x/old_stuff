class Edit < DomainModel::Actions::Action	
	inherit DomainModel::Transactional
	
	def build_dmeta
		h = H.new
		
		h.e :name, :string_edit
		h.e :text, :richtext_edit
		
		h.b :ok, :button, "Ok", {:inputs => :view} do
			update
			controller.execute :on_view
		end
		
		h.b :cancel, :button, "Cancel" do
			controller.restore_view
		end
		
		h.container :toolbar, :flow, {:floating => true, :padding => true, :highlithed => true}, [:ok, :cancel]
		
		h.container :view, :box, {:padding => true}, [
		:toolbar,
		:name,		
		:text
		]	
		
		@wigets = h.wigets		
	end
	
	def execute
		controller.save_view
		
		controller.view = @wigets[:view]
		view_context.wigets = @wigets
		view_context.wigets.values.every.respond_to :read, object							
	end
	
	protected
	def update				
		new_values = {}		
		view_context.wigets.values.every.respond_to :write, new_values
		op = OGDomain::Operations::EditProperties.new.set :entity => object, 
		:attributes => [:name, :text], :properties => new_values
		op.validate; op.build; op.execute
	end
	transactional :update		
end