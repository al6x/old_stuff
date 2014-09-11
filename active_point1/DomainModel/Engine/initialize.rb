module DomainModel		
	Scope.register :storage, :application do
		OGCore::CONFIG[:directory] = CONFIG[:directory]
		OGCore::CONFIG[:transaction_strategy] = OGCore::Transaction::MicroContainerDeclarativeStrategy::StrategyAdapter
		OGCore::Transaction::MicroContainerDeclarativeStrategy::SessionTransactions.scope :object	
		
		root_class = nil
		begin
			root_class = eval CONFIG[:root_class], TOPLEVEL_BINDING, __FILE__, __LINE__
		rescue Exception => e
			log.error "Can't evaluate Root Class (#{e.message})"
			raise e
		end		
		OGDomain::Engine.new(:storage, root_class)		
	end
	
	Scope.register :root, :application do
		Scope[:storage].root
	end
	
	OGDomain::Entity.build_dmeta do |m|
		m.attribute :name, :string, "Name"
		m.mandatory :name
	end
	
	# Storage Initialization
	begin	
		storage = Scope[:storage]
		if storage.root.core == nil
			Core::Initializer.new.initialize_storage storage
			custom_initializer = begin
				eval CONFIG[:initializer], TOPLEVEL_BINDING, __FILE__, __LINE__
			rescue Exception => e
				log.error "Can't evaluate Initializer Class (#{e.message})"
				raise e
			end					
			custom_initializer.new.initialize_storage storage if custom_initializer
		end
	end
end