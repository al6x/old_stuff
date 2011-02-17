module MongoMapper
  module Plugins
    module TextProcessor
      
      module ClassMethods
        def markup_key attr_name, opt = {}
          attr_name = attr_name.to_s
          opt = opt.to_openobject
          original_attr_name = "original_#{attr_name}"
          
          key original_attr_name, String
          key attr_name, String, :protected => true unless keys.keys.include? attr_name
                  
          validates_presence_of attr_name, original_attr_name if opt.required?
          
          alias_method "#{attr_name}_without_markup=", "#{attr_name}="
          alias_method "#{original_attr_name}_without_markup=", "#{original_attr_name}="
          
          define_method "#{attr_name}=" do |value|            
            send "#{original_attr_name}_without_markup=", value
            send "#{attr_name}_without_markup=", value
          end
                  
          define_method "#{original_attr_name}=" do |value|
            send "#{original_attr_name}_without_markup=", value
            send "#{attr_name}_without_markup=", TextUtils.markup(value)
          end
          
          define_method "#{attr_name}_as_text" do
            value = send(attr_name)
            return "" if value.blank?
            Nokogiri::XML(value).content
          end
                  
          ce_method_name = "copy_errors_for_#{attr_name}"
          define_method ce_method_name do
            if !errors.on(original_attr_name) and (err = errors.on(attr_name))
              errors.add original_attr_name, err
            end
          end
          after_validation ce_method_name          
        end
      end
      
    end
  end
end