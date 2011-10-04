class InMemoryCache < Hash
	def initialize repository, *parameters
		super()
	end
		
	def update transaction
		transaction.copies.each{|entity_id, c| delete entity_id if c.deleted?}
	end
end