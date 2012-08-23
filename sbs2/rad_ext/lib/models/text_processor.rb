module Models::TextProcessor
  module ClassMethods
    def available_as_markup attr_name
      original_attr_name = :"original_#{attr_name}"

      raise "attribute #{attr_name} not defined!" unless method_defined? attr_name
      attr_reader original_attr_name              unless method_defined? original_attr_name

      iv_name, original_iv_name = :"@#{attr_name}", :"@#{original_attr_name}"

      define_method :"#{attr_name}=" do |value|
        instance_variable_set iv_name, value
        instance_variable_set original_iv_name, value
      end

      define_method "#{original_attr_name}=" do |value|
        instance_variable_set iv_name, TextUtils.markup(value)
        instance_variable_set original_iv_name, value
      end

      define_method "#{attr_name}_as_text" do
        value = instance_variable_get iv_name
        return "" if value.blank?
        Nokogiri::XML(value).content
      end

      after_validate do |model|
        model.errors.add original_attr_name, model.errors[attr_name] if model.errors.include?(attr_name)
      end
    end
  end
end