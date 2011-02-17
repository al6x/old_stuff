# Extending
module ActivePoint
#	::ObjectModel::CONFIG[:cache] = CONFIG[:cache]
	
	# Implicit Transaction
	Scope.register :transaction, :transaction do
		TransactionStrategy.create_new
	end	
	
	class TransactionStrategy
		def initialize repository; end		
		def create_new; Scope[:transaction] end		
		def after_commit transaction; Scope[:transaction] = TransactionStrategy.create_new end
			
		def self.create_new
			t = ::ObjectModel::Transaction.new
			t.managed = true
			t
		end
	end
end