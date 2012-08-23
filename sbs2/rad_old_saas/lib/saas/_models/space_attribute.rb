# TODO3 use standalone UserData class
module Models::SpaceAttribute
  module ClassMethods
    def space_attribute attr_name, options = {}
      attr_name.must.be_a Symbol
      raise "default value not specified!" unless options.include? :default
      raise "standalone value not specified!" unless options.include? :standalone

      default, standalone = options.delete(:default), options.delete(:standalone)
      space_attr_name = "space_#{attr_name}".to_sym
      space_iv_name = :"@#{space_attr_name}"

      # options[:protected] = true
      define_method space_attr_name do
        unless value = instance_variable_get(space_iv_name)
          value = {}
          instance_variable_set space_iv_name, value
        end
        value
      end

      define_method attr_name do
        if rad.include? :space
          space_id = rad.space._id.to_s
          self.send(space_attr_name)[space_id] || default.clone
        else
          standalone.clone
        end
      end

      define_method :"#{attr_name}=" do |value|
        if rad.include? :space
          space_id = rad.space._id.to_s
          if value == default
            self.send(space_attr_name).delete space_id
          else
            self.send(space_attr_name)[space_id] = value
          end
          value
        else
          raise "there's no active :space component (you can't assign values to :space_attribute if there's no active :space)!"
        end
      end

    end
  end

end