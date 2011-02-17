module MongoMapper
  module Plugins
    module Multitenant
      
      module ClassMethods                
        def connect_to_global_database!      
          use_database :global
        end
        
        def belongs_to_space!
          keys.symbolize_keys.should_not! :include, :account_id
          
          key :account_id, ObjectId, :default => lambda{Account.current? ? Account.current.id : nil}, :protected => true
          belongs_to :account

          key :space_id, ObjectId, :default => lambda{Space.current? ? Space.current.id : nil}, :protected => true
          belongs_to :space    

          validates_presence_of :account_id, :space_id

          default_scope do 
            Space.current? ? {:space_id => Space.current.id} : {}
          end
          
          ensure_index :account_id
          ensure_index :space_id
        end        
      end
      
    end
  end
end