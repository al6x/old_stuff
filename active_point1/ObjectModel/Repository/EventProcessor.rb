class EventProcessor
	def initialize transaction
		@transaction = transaction
		@before_history = []
	end		
	
	def fire_before entity, event, *params
		entity.should! :be_a, Entity
		event.should! :be_in, Metadata::BEFORE_EVENT_TYPES
		
		l_event = :"before_#{event}"
		@transaction.repository.entity_listeners.each{|l| l.respond_to l_event, entity, *params}
		@transaction.system_listener.respond_to l_event, entity, *params
		
		entity.meta.before.fire entity, event, *params		
	end
	
	def fire_after entity, event, *params
		entity.should! :be_a, Entity
		event.should! :be_in, Metadata::AFTER_EVENT_TYPES
		
		l_event = :"after_#{event}"
		@transaction.repository.entity_listeners.each{|l| l.respond_to l_event, entity, *params}
		@transaction.system_listener.respond_to l_event, entity, *params
		
		entity.meta.after.fire entity, event, *params
	end
	
	def fire_before_commit
		entities = []
		@transaction.copies.each do |om_id, c|
			entities << @transaction.resolve(om_id)												
		end
		
		@transaction.repository.entity_listeners.each{|l| l.respond_to :before_commit, entities}
		@transaction.system_listener.respond_to :before_commit, entities					
		
		entities.each{|e| e.meta.before.fire e, :commit}
	end
	
	def fire_after_commit
		entities = []
		@transaction.copies.each do |om_id, c|
			entity = if @transaction.deleted_entities.include? om_id
				@transaction.deleted_entities[om_id]
			else
				@transaction.resolve om_id
			end
			entities << entity			
		end		
		
		# :after_commit
		@transaction.repository.entity_listeners.each{|l| l.respond_to :after_commit, entities}
		@transaction.system_listener.respond_to :after_commit, entities					
		
		entities.each{|e| e.meta.after.fire e, :commit}
	end
end