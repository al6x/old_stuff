class Add < DomainModel::Actions::Action	
	inherit DomainModel::Transactional			
	
	def execute
		child = add
		controller.object = child
		controller.execute :edit							
	end
	
	protected
	def add
		child = Page.new	
		op = OGDomain::Operations::EditChild.new
		op.set :attribute => :children, :entity => object, :child => child, :mode => :update
		op.validate; op.build; op.execute
		child.name = "new"
		return child
	end
	transactional :add
end