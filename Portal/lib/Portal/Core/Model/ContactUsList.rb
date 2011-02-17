class ContactUsList
	inherit Entity
	
	metadata do
		child :contacts, :bag
	end
end