module FileModel::Helper
  module ClassMethods
    def mount_file attr_name, file_model_class
      attr_name.must.be_a Symbol
      iv_name = :"@_#{attr_name}"

      define_method attr_name do
        unless file_model = instance_variable_get(iv_name)
          file_name = attribute_get attr_name

          file_model = file_model_class.new
          file_model.model = self
          file_model.read file_name

          instance_variable_set iv_name, file_model
        end
        file_model
      end

      define_method :"#{attr_name}=" do |file|
        file_model = send(attr_name)
        file_model.original = file

        file_name = file_model.build_name file_model.original.name
        attribute_set attr_name, file_name
      end
    end
  end
end