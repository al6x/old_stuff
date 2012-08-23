# 
# ObjectID
# 
# Mongo::ObjectID.class_eval do  
#   def == other
#     self.to_s == other.to_s
#   end
# 
#   def to_yaml *args
#     to_s.to_yaml *args
#   end
# end


# 
# Fixes
# 
if Object.const_defined?(:RAILS_ENV) and Object.const_get(:RAILS_ENV) != 'production'
  MongoMapper::Document::ClassMethods.class_eval do
    def ensure_index(name_or_array, options={})
    end
  end
end


MongoMapper::Plugins::Associations::InArrayProxy.class_eval do
  def delete(doc)
    ids.delete(doc.id)
    klass.delete(doc.id)
    reset
  end
end
