class DefaultTransactionStrategy
	def initialize repository; end
	
	def create_new
			Repository::Transaction.new
	end
	
	def after_commit transaction; end
end