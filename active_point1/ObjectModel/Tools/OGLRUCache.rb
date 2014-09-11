# It should have max_items at least equal to 1!
class OGLRUCache < LRUCache
	class EntityContainer
		include LRUCache::Item
		
		attr_reader :entity
		def initialize entity
			@entity = entity
		end
	end
	
	def initialize repository, percentage
		@repository, @percentage = repository, percentage
		super(1)
		update_size
	end
	
	def [](key)
		container = super(key)
		nil == container ? nil : container.entity
	end
	
	def []=(key, item)
		container = EntityContainer.new item
		super(key, container)
	end
	
	def update transaction
		transaction.copies.each{|om_id, c| delete om_id if c.deleted?}		
		update_size
	end
	
	protected
	def update_size
		self.max_items = (@repository.size * @percentage).floor + 1
	end
end