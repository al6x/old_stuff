class Transaction
	attr_reader :copies, :name, :new_entities, :event_processor, :repository, :system_listener, :deleted_entities	
	attr_writer :repository, :name
	attr_accessor :managed
	
	def initialize
		@name = "default"
		@copies = Hash.new{|hash, key| raise "Can't find Copy for '#{key}'entity_id!"}
		@new_entities = Hash.new{|hash, key| raise "Can't find New Entity for '#{key}' entity_id!"}
		@deleted_entities = Hash.new{|hash, key| raise "Can't find Deleted Entity for '#{key}' entity_id!"}
		@event_processor = EventProcessor.new(self)
		@system_listener = SystemListener.new(self)
		@commited = false
		@managed = false
	end
	
	def copy_get! entity			
		unless @copies.include? entity.entity_id
			copy = AnEntity::EntityType.create_copy entity
			@copies[entity.entity_id] = copy
		end
		@copies[entity.entity_id]
	end	
	
	def resolve entity_id
		if @new_entities.include? entity_id
			@new_entities[entity_id]		
		elsif @deleted_entities.include? entity_id
			@deleted_entities[entity_id]
		else
			@repository.by_id(entity_id)
		end
	end
	
	def commited!
		@commited = true
	end
	
	def commited?
		@commited
	end
	
	def commit
		@repository.commit self
	end
	
	def changed? entity_id
		entity_id.should! :be_a, String
		@copies.include?(entity_id) || @new_entities.include?(entity_id)
	end		
	
	def to_s
		types = {:new => 0, :deleted => 0, :updated => 0, :moved => 0}		
		methods = types.keys
		@copies.values.each do |c|
			methods.each do |m| 
				types[m] += 1 if c.send :"#{m}?"
			end		
		end		
		return "#<Transaction: #{@name}#{commited? ? ", commited" : ""}, #{types.inspect}>"
	end
	alias_method :inspect, :to_s	
end