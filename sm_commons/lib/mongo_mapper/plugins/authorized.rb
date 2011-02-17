module MongoMapper
  module Plugins
    module Authorized            
      ROLES = %w{admin manager member}
      
      module ClassMethods
        def acts_as_authorized
          key :global_admin, Boolean, :protected => true
          key :admin_of_accounts, Array, :protected => true
          # has_many :roles_containers, :class_name => 'RolesContainer', :protected => true          
          space_key :space_roles, Array
          
          validate :validate_anonymous
          validates_exclusion_of :name, :within => Role::PRESERVED_USER_NAMES, :if => lambda{|u| u.new_record?}
        end
        
        def anonymous
          User.find_by_name 'anonymous'
        end
      end
      
      module InstanceMethods
        # 
        # Owner
        # 
        def owner_name; anonymous? ? nil : name end
        
        def owner? object
          # object.should! :respond_to?, :owner_name
          !object.blank? and !name.blank? and object.respond_to(:owner_name) == self.name
        end
        
        # 
        # Roles
        # 
        def anonymous?
          name == 'anonymous'
        end

        def registered?
          !anonymous?
        end
      
        def add_role role
          role = role.to_s
          ::Rails.should_be! :multitenant_mode
          
          if role == 'admin'
            account_id = Account.current.id
            admin_of_accounts << account_id unless admin_of_accounts.include? account_id
          else              
            roles = Role.denormalize_to_lower_roles [role]
            self.space_roles = space_roles + [role] unless space_roles.include?(role)
          end          
          clear_cache
          roles
        end
      
        def remove_role role
          role = role.to_s
          ::Rails.should_be! :multitenant_mode
                    
          if role == 'admin'
            admin_of_accounts.delete Account.current.id
          else          
            roles = Role.denormalize_to_higher_roles [role]
            self.space_roles = space_roles - roles
          end
          clear_cache
          roles
        end
            
        def roles        
          unless roles = cache[:roles]
            if ::Rails.multitenant_mode?
              roles = space_roles.clone
              roles << 'admin' if admin_of_accounts.include? Account.current.id
            else
              roles = []
            end
          
            roles << 'user'
          
            if anonymous?
              roles << 'anonymous'
            else
              roles << 'registered'
            end

            roles << "user:#{name}" unless name.blank?
          
            roles << 'admin' if global_admin and !roles.include?('admin')
            
            roles << 'manager' if roles.include?('admin') and !roles.include?('manager')
            
            roles = Role.denormalize_to_lower_roles(roles)
            
            roles = HandyRoles.new roles
                      
            cache[:roles] = roles
          end
          roles
        end

        def major_roles
          cache[:major_roles] ||= Role.major_roles roles
        end
      
        def has_role? role
          roles.include? role
        end
        
        
        # 
        # can?
        #       
        def can? operation, object = nil
          operation = operation.to_s
          
          return true if has_role?(:admin)
          
          custom_method = "able_#{operation}?"          
          return object.send custom_method, self if object.respond_to? custom_method
          
          effective_space_permissions[operation] or (
            owner?(object) and effective_space_permissions_as_owner[operation]
          )
        end
        
        def can_view? object
          can? :view, object
        end
        
        
        # 
        # Effective Permissions
        # 
        def effective_space_permissions
          unless effective_space_permissions = cache[:effective_space_permissions]          
            effective_space_permissions = calculate_effective_roles_for roles
            cache[:effective_space_permissions] = effective_space_permissions
          end
          effective_space_permissions
        end

        def effective_space_permissions_as_owner
          unless effective_space_permissions_as_owner = cache[:effective_space_permissions_as_owner]          
            effective_space_permissions_as_owner = calculate_effective_roles_for ['owner']
            cache[:effective_space_permissions_as_owner] = effective_space_permissions_as_owner
          end
          effective_space_permissions_as_owner
        end
        
        protected
          # def effective_space_roles
          #   ::Rails.should_be! :multitenant_mode        
          #   unless roles = cache[:effective_space_roles]
          #     roles = space_roles.clone
          #     roles << 'admin' if admin_of_accounts.include? Account.current.id
          #     cache[:effective_space_roles] = roles
          #   end
          #   roles
          # end
        
          def validate_anonymous          
            if anonymous? and (global_admin or !space_roles.blank?)
              errors.add :base, "Anonymous can't be member or manager!"
            end
          end
      
          class HandyRoles < Array
            def include? role
              super role.to_s
            end
            alias_method :has?, :include?

            def method_missing m, *args, &block
              m = m.to_s
              super unless m.last == '?'

              self.include? m[0..-2]
            end
          end
          
          def calculate_effective_roles_for roles
            permissions = ::Rails.multitenant_mode? ? Space.current.permissions : Space.permissions
            effective_space_permissions = {}
            permissions.each do |operation, allowed_roles|
              effective_space_permissions[operation] = roles.any?{|role| allowed_roles.include? role}
            end
            effective_space_permissions
          end
      end
      
    end
  end
end