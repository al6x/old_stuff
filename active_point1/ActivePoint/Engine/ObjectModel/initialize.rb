# Extending
module ActivePoint
	::ObjectModel::CONFIG[:cache] = "ObjectModel::Tools::OGLRUCache"
	
	# Implicit Transaction
	Scope.register :transaction, :transaction do
		TransactionStrategy.create_new
	end
	Scope.group(:object) << :transaction
	
	class TransactionStrategy
		def initialize repository; end		
		def create_new; Scope[:transaction] end		
		def after_commit transaction; Scope[:transaction] = TransactionStrategy.create_new end
			
		def self.create_new
			t = ObjectModel::Transaction.new
			t.managed = true
			t
		end
	end
	
	# Repository Initialization
	Scope.register :repository, :application do
		dir = "#{CONFIG[:directory]}/ObjectModel"
		File.create_directory dir unless File.exist? dir		
		
		r = ObjectModel::Repository.new :repository, \
		:transaction_strategy => ActivePoint::TransactionStrategy,
		:directory => dir
		r.entity_listeners << Engine::ObjectModel::Listener.new
		r
	end			
end