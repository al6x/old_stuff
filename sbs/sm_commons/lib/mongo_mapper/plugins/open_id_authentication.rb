module MongoMapper
  module Plugins
    module OpenIdAuthentication
      
      module InstanceMethods
        def authenticated_by_open_id? open_id
          self.open_id == open_id
        end
      end
    
      module ClassMethods
        def acts_as_authenticated_by_open_id!
          key :open_ids, Array
          
          ensure_index :open_ids

          validates_uniqueness_of :open_ids, :allow_blank => true
        end
      
        def authenticate_by_open_id open_id
          return nil if open_id.blank?
          User.first :conditions => {:state => 'active', :open_ids => open_id}
        end
      end
    end
  end
end