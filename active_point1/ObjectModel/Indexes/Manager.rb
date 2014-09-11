class Manager
	attr_accessor :indexes
	
	def initialize repository
		@repository = repository
		@indexes = Hash.new{|hash, key| raise_without_self "No Index - '#{key}'!", ObjectModel}
		@not_initialized = Set.new
	end
	
	def add index
		index.name.should! :be_a, Symbol
		@indexes[index.name] = index		
		index.storage = @repository.indexes_storage
		index.repository = @repository
		builded = index.create_index
		@not_initialized << index unless builded
	end		
	
	def delete index_name
		index_name.should! :be_a, Symbol
		index = @indexes.delete index_name
		index.should_not! :be_nil
		index.delete_index
		@not_initialized.delete index
	end
	
	def update transaction		
		Thread.current[:om_transaction].should_not! :be_nil		
		@not_initialized.should! :be_empty
		
		@repository.indexes_storage.transaction do
			indexes = @indexes.values
			transaction.copies.each do |om_id, c| 
				e = transaction.resolve om_id
				indexes.every.update e, c					
			end
		end
	end
	
	def [] name		
		check_transaction	
		@not_initialized.should! :be_empty
		return @indexes[name]
	end
	
	def get_index_without_transaction_check name
		@not_initialized.should! :be_empty
		return @indexes[name]
	end		
	
	def clear_indexes
		check_transaction
		@indexes.values.every.delete_index
		@not_initialized.replace @indexes.values
	end
	
	def build_indexes
		check_transaction
		@not_initialized.every.create_index
		@repository.indexes_storage.transaction do
			@repository.each{|e| @not_initialized.every.add e}
		end
		@not_initialized.clear
	end		
	
	protected
	def check_transaction
		#		if Thread.current[:om_transaction]
		#			raise_without_self "Forbiden to use Indexes inside Transaction!", ObjectModel
		#		end
	end
end