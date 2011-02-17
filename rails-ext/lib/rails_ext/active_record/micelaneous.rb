if defined?(ActiveRecord)
  ActiveRecord::Base.send :class_eval do
  
    def dom_id
      new_record? ? "new_#{self.class.name.underscore}" : "#{self.class.name.underscore}_#{id}"
    end
  
  
    # 
    # handy accessor for @attributes_cache
    #
    attr_reader :attributes_cache
  end
end