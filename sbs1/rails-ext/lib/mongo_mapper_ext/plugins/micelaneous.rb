module MongoMapper
  module Plugins
    module Micelaneous
      
      module InstanceMethods
        def upsert *args
          self.class.upsert id, *args
        end
      end
      
      module ClassMethods
        # 
        # Sequentiall :all for big collection
        # 
        def all_sequentially &block
          page, per_page = 1, 5
          begin
            results = paginate(:page => page, :per_page => per_page, :order => '_id asc')
            results.each{|o| block.call o}
            page += 1
          end until results.blank? or results.size < per_page
        end
        
        
        # 
        # Connect to database_alias specified in config
        # 
        def use_database database_alias          
          database_alias = database_alias.to_s
          MongoMapper.db_config.should! :include, database_alias

          self.connection MongoMapper.connections[database_alias]
          set_database_name MongoMapper.db_config[database_alias]['name']
        end        
        
        
        # 
        # shortcut for upsert
        # 
        def upsert *args
          collection.upsert *args          
        end
        
        
        # 
        # CounterCache
        # belongs_to :item, :counter_cashe => true
        # 
        def belongs_to association_id, options={}, &extension          
          options.should_not! :include, :counter_cashe
          if options.delete(:counter_cache) || options.delete('counter_cache')
            association_id = association_id.to_s
            association_key = "#{association_id}_id"
            cache_attribute = "#{name.pluralize.underscore}_count"
            cache_class = association_id.classify.constantize
            cache_class.keys.should! :include, cache_attribute            
            increase_method_name = "increase_#{cache_class.name.underscore}_#{name.pluralize.underscore}_counter"
            decrease_method_name = "decrease_#{cache_class.name.underscore}_#{name.pluralize.underscore}_counter"
            
            define_method increase_method_name do
              cache_class.upsert self.send(association_key), :$inc => {cache_attribute => 1}
            end
            protected increase_method_name            
            
            define_method decrease_method_name do
              cache_class.upsert self.send(association_key), :$inc => {cache_attribute => -1}
            end
            protected decrease_method_name
            
            after_create increase_method_name
            after_destroy decrease_method_name
          end
          
          super association_id, options, &extension
        end
        
      end
      
    end
  end
end