module Mongoid::Miscellaneous
  extend ActiveSupport::Concern
  
  def upsert! *args
    self.class.upsert!({id: id}, *args)
  end
  
  def exist?
    self.class.where(_id: id).count > 0
  end
  alias_method :exists?, :exist?
  
  def dom_id
    new_record? ? "new_#{self.class.name.underscore}" : to_param
  end
  
  def first! *a
    super || raise(Mongoid::Errors::DocumentNotFound.new(self, a))
  end
  
  def set_protected_attributes attribute_names, attributes
    attribute_names.each do |name|
      send "#{name}=", attributes[name] if attributes.include? name
    end
  end
  
  def t *a
    I18n.t *a
  end
  
  module ClassMethods       
    # # 
    # # Database aliases
    # # 
    # def set_database_alias als
    #   name = Mongoid.database_aliases[als] || raise("unknown database alias '#{als}'!")
    #   set_database name
    # end
    
             
    # 
    # model_name
    # 
    def model_name *args
      if args.empty?
        @model_name ||= ::ActiveModel::Name.new self, self.alias
      else
        @model_name = ::ActiveModel::Name.new self, args.first
      end          
    end
    
    
    # 
    # Sequentiall :all for big collection
    # 
    def all_sequentially &block
      page, per_page = 1, 5
      begin
        results = paginate(page: page, per_page: per_page, order: '_id asc')
        results.each{|o| block.call o}
        page += 1
      end until results.blank? or results.size < per_page
    end
    
    
    # 
    # shortcut for upsert
    # 
    def upsert! query, *args
      query[:_id] = query.delete :id if query.include? :id
      collection.upsert! query, *args          
    end
       
         
    def to_param
      (id || '').to_s
    end    
  end
  
end


# # 
# # Database aliases
# # 
# module Mongoid
#   def self.database_aliases; @database_aliases ||= {} end
#   def self.set_database_aliases aliases
#     database_aliases.merge! aliases
#   end
# end