# 
# Allow to specify different model name than class name
# 
ActiveModel::Name.class_eval do
  def initialize klass, name = nil
    name ||= klass.name
    
    super name
    
    @klass = klass
    @singular = ActiveSupport::Inflector.underscore(self).tr('/', '_').freeze
    @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
    @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).freeze
    @human = ActiveSupport::Inflector.humanize(@element).freeze
    @collection = ActiveSupport::Inflector.tableize(self).freeze
    @partial_path = "#{@collection}/#{@element}".freeze
    @i18n_key = ActiveSupport::Inflector.underscore(self).tr('/', '.').to_sym
  end
end


# 
# Mongoid uses Proxy over Mongo::Collection, so we need to define all extra method on this proxy by hands
# 
%w(upsert!).each do |name|
  Mongoid::Collection.send(:define_method, name){|*args| master.collection.send(name, *args)}
end


# 
# Default value on the :foreign_key
# 
Mongoid::Relations::Metadata.class_eval do
  def foreign_key_default_with_options
    self[:default] || foreign_key_default_without_options
  end
  alias_method_chain :foreign_key_default, :options
end


# 
# dynamic default scope
# 
