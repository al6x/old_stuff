module Mongoid::BelongsToWithCounterCache
  extend ActiveSupport::Concern

  module ClassMethods        
    # 
    # CounterCache
    # belongs_to :item, counter_cashe: true
    # 
    def belongs_to name, options = {}, &block      
      add_counter_cache name, options if options.delete(:counter_cache)
      super
    end
    
    protected
      def add_counter_cache name, options
        name = name.to_s
        association_field = "#{name}_id"
        cache_attribute_field = "#{self.alias.pluralize.underscore}_count"
        cache_class = if class_name = options[:class_name]
          class_name.constantize
        else
          name.classify.constantize
        end
        raise "field :#{cache_attribute_field} not defined on :#{cache_class}!" unless cache_class.fields.include? cache_attribute_field            
        increase_method_name = "increase_#{cache_class.alias.underscore}_#{self.alias.pluralize.underscore}_counter"
        decrease_method_name = "decrease_#{cache_class.alias.underscore}_#{self.alias.pluralize.underscore}_counter"

        define_method increase_method_name do
          cache_class.upsert!({id: self.send(association_field)}, :$inc => {cache_attribute_field => 1})
        end
        protected increase_method_name            

        define_method decrease_method_name do
          cache_class.upsert!({id: self.send(association_field)}, :$inc => {cache_attribute_field => -1})
        end
        protected decrease_method_name

        after_create increase_method_name
        after_destroy decrease_method_name
      end
  end
  
end