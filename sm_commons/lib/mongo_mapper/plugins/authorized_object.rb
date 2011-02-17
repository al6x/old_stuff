module MongoMapper
  module Plugins
    module AuthorizedObject
      
      module ClassMethods
        def acts_as_authorized_object
          key :owner_name, String, :default => lambda{User.current? ? User.current.name : nil}, :protected => true
          key :collaborators, Array, :protected => true
          # Contains the role and all upper roles. So complex becouse we need it in indexes.
          key :viewers, Array, :default => lambda{User.current? ? ["user:#{User.current.name}", 'manager'].sort : ['manager']}, :protected => true
         
          validates_presence_of :owner_name
          validate :validate_viewers
          validate :validate_collaborators
        end        
      end
      
      module InstanceMethods
        # 
        # Owner
        # 
        def owner
          return nil if owner_name.blank?
          cache[:owner] ||= User.find_by_name! owner_name
        end      
      
        def owner= user
          user.should! :be_a, User
          cache[:owner] = user
          self.owner_name = user.name
          user
        end
            
        # TODO2 update it later, MM uses public API to unmarshal object 
        # http://groups.google.com/group/mongomapper/browse_thread/thread/ab34457e0ba9c472#
        def owner_name= name                    
          owner_role = "user:#{name}"
          old_owner_role = "user:#{owner_name}"
          
          unless viewers.include? owner_role
            viewers.delete old_owner_role
            viewers << owner_role
            viewers.sort!
          end
          
          # write_attribute :owner_name, name
          super name
          clear_cache
          owner_name
        end
      
        # 
        # Viewers and Collaborators
        # 
        def add_viewer role
          role = role.to_s
          should_be_valid_user_input_role role                    
          
          return if viewers.include? role          
          
          roles = viewers
          roles << role
          roles = Role.denormalize_to_higher_roles roles
          roles << 'manager' unless roles.include? 'manager'
          self.viewers = roles.sort
          viewers
        end
        
        def remove_viewer role
          role = role.to_s
          should_be_valid_user_input_role role          
          
          return unless viewers.include? role
          
          roles = viewers
          Role.denormalize_to_higher_roles([role]).each do |r|
            roles.delete r
          end
          roles << 'manager' unless roles.include? 'manager'
          self.viewers = roles.sort
          
          remove_collaborator role
          
          viewers
        end
        
        def minor_viewers
          unless minor_viewers = cache[:minor_viewers]
            viewers = self.viewers.clone
            viewers.delete 'manager'
            minor_viewers = Role.minor_roles viewers
            cache[:minor_viewers] = minor_viewers
          end
          minor_viewers
        end
        
        def add_collaborator role
          role = role.to_s
          should_be_valid_user_input_role role
          return if collaborators.include? role
          collaborators = self.collaborators.clone       
          collaborators << role
          self.collaborators = collaborators
          
          add_viewer role
          
          collaborators
        end
        
        def remove_collaborator role
          role = role.to_s
          should_be_valid_user_input_role role                    
          collaborators.delete role
          collaborators
        end
        
        def normalized_collaborators
          unless normalized_collaborators = cache[:normalized_collaborators]
            normalized_collaborators = Role.denormalize_to_higher_roles collaborators
            normalized_collaborators << "user:#{owner_name}"
            normalized_collaborators.sort!
            cache[:normalized_collaborators] = normalized_collaborators
          end
          normalized_collaborators
        end
        
        
        # 
        # Special Permissions
        # 
        def able_view? user
          user.roles.any?{|role| viewers.include? role}
        end
        
        def able_update? user
          user.roles.any?{|role| normalized_collaborators.include? role}
        end
        
        protected        
          def should_be_valid_user_input_role role
            # ::Rails.should_be! :multitenant_mode
            # (Role::ORDERED_ROLES + Space.current.custom_roles).should! :include, role.to_s
            role.should_not! :==, 'manager'
            role.should_not! :==, "user:#{owner_name}"
          end
        
          def validate_viewers
            viewers.should! :==, viewers.uniq
                                        
            viewers.should! :include, 'manager' # always
            viewers.should! :include, "user:#{owner_name}"
          end
          
          def validate_collaborators
            collaborators.should_not! :include, "user:#{owner_name}"
          end
      end
      
      # module ClassMethods
      #   def can? operation, user
      #     method = "can_#{operation}?"
      #     if respond_to? method
      #       send method, user
      #     else
      #       user.effective_space_permissions[operation]
      #     end
      #   end        
      # end
    end
  end
end