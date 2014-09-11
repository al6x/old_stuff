class Delete < DomainModel::Actions::Action	
	inherit DomainModel::Transactional
	attr_accessor :selected
	
	def execute
		delete									
		controller.execute :on_view
	end			
	
	protected
	def delete
		selected.each_with_index do |del, i|
			next unless del
			op = OGDomain::Operations::EditChild.new
			op.set :attribute => :children, :entity => object, :index => i, :mode => :delete
			op.validate; op.build; op.execute
		end
	end
	transactional :delete
end