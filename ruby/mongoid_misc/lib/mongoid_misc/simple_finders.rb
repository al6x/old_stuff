module Mongoid::SimpleFinders
  extend ActiveSupport::Concern  
  
  module ClassMethods
    def method_missing clause, *a, &b
      if clause =~ /^([a-z]_by_[a-z_])|(by_[a-z_])/ 
        clause = clause.to_s      
      
        bang = clause =~ /!$/
        clause = clause[0..-2] if bang
      
        finder, field = if clause =~ /^by_/  
          ['first', clause.sub(/by_/, '')]
        else        
          clause.split(/_by_/, 2)          
        end                
        finder = 'first' if finder == 'find'
      
        raise "You can't use bang version with :#{finder}!" if bang and finder != 'first'
      
        raise "invalid arguments for finder (#{a})!" unless a.size == 1
        field_value = a.first

        where(field => field_value).send(finder) || 
          (bang && raise(Mongoid::Errors::DocumentNotFound.new(self, field_value)))
      else
        super
      end
    end
    
    # 
    # find_by_id, special case
    # 
    def find_by_id id
      where(_id: id).first
    end
    alias_method :by_id, :find_by_id

    def find_by_id! id
      find_by_id(id) || raise(Mongoid::Errors::DocumentNotFound.new(self, id))
    end
    alias_method :by_id!, :find_by_id!
  end
end