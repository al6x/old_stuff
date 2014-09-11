class Config 
	extend Configurator
	
	initialize_data do
		R.transaction(Transaction.new){
			Model::Page.new("Welcome").set \
			:greeting => "Welcome a board",
			:detail => "You are on ActivePoint!"
		}.commit
	end
end