class InMemoryCache < Hash
	def initialize repository, *parameters
		super()
	end
		
	def update transaction
		transaction.copies.each{|om_id, c| delete om_id if c.deleted?}
	end
end