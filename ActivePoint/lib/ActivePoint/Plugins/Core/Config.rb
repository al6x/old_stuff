class Config
	extend Configurator
	
	initialize_data do		
		R.transaction(Transaction.new){			
			CONFIG[:initialize_core].call
		}.commit
	end
end