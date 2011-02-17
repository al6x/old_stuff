module MongoMapper
  module Plugins
    module SpaceKeys
      
      class SpaceKeysContainer
        include MongoMapper::EmbeddedDocument
        key :space_id, ObjectId
        
        SKIP_KEYS = %w{_id space_id}
        
        def blank?
          self.class.keys.keys.select{|k| !SKIP_KEYS.include?(k.to_s)}.all?{|k| value = send(k); value.blank? or value == 0}          
        end
      end
      
      module InstanceMethods        
        def get_create_or_delete_space_keys_container modifying_operation, &block
          ::Rails.should_be! :multitenant_mode
          
          unless modifying_operation
            container = space_keys_containers.select{|c| c.space_id == Space.current.id}.first || \
              SpaceKeysContainer.new(:space_id => Space.current.id)
            block.call container
          else
            container = space_keys_containers.select{|c| c.space_id == Space.current.id}.first || \
              space_keys_containers.build(:space_id => Space.current.id)              
            block.call container            
            space_keys_containers.delete container if container.blank?
          end
        end
      end
      
      module ClassMethods
        def space_key key, type, options = {}
          define_space_keys_containers
          
          SpaceKeysContainer.send :key, key, type, options
          
          define_method key do
            get_create_or_delete_space_keys_container false do |container|
              container.send key
            end
          end
          
          define_method "#{key}=" do |value|
            get_create_or_delete_space_keys_container true do |container|
              container.send "#{key}=", value
              value
            end
          end
        end        
        
        def define_space_keys_containers
          unless associations.keys.include? 'space_keys_containers'
            has_many :space_keys_containers, :class_name => 'MongoMapper::Plugins::SpaceKeys::SpaceKeysContainer', :protected => true
          end
        end      
      end
      
    end
  end
end