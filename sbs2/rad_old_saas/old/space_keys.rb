module MongoMapper::Plugins::SpaceAttributes

  class SpaceAttributesContainer
    include MongoMapper::EmbeddedDocument
    key :space_id, ObjectId

    SKIP_KEYS = %w{_id space_id}

    def blank?
      self.class.keys.keys.select{|k| !SKIP_KEYS.include?(k.to_s)}.all?{|k| value = send(k); value.blank? or value == 0}
    end
  end

  module InstanceMethods
    def get_create_or_delete_space_attributes_container modifying_operation, &block
      Rad.multitenant_mode?.must.be_true

      unless modifying_operation
        container = space_attributes_containers.select{|c| c.space_id == Space.current._id}.first || \
          SpaceAttributesContainer.new(space_id: Space.current._id)
        block.call container
      else
        container = space_attributes_containers.select{|c| c.space_id == Space.current._id}.first || \
          space_attributes_containers.build(space_id: Space.current._id)
        block.call container
        space_attributes_containers.delete container if container.blank?
      end
    end
  end

  module ClassMethods
    def space_attribute key, type, options = {}
      define_space_attributes_containers

      SpaceAttributesContainer.send :key, key, type, options

      define_method key do
        get_create_or_delete_space_attributes_container false do |container|
          container.send key
        end
      end

      define_method "#{key}=" do |value|
        get_create_or_delete_space_attributes_container true do |container|
          container.send "#{key}=", value
          value
        end
      end
    end

    def define_space_attributes_containers
      unless associations.keys.include? 'space_attributes_containers'
        has_many :space_attributes_containers, class_name: 'MongoMapper::Plugins::SpaceAttributes::SpaceAttributesContainer', protected: true
      end
    end
  end

end