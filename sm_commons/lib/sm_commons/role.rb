class Role
  ORDERED_ROLES = %w{manager member user}
  SYSTEM_ROLES = %w{admin anonymous manager member owner registered user}.sort.freeze
  PRESERVED_USER_NAMES = (SYSTEM_ROLES + ['admin']).sort.freeze

  class << self
  
    def normalize_roles roles    
      ordinary_roles, ordered_roles = split roles
      ordinary_roles << lower_role(ordered_roles)    
      ordinary_roles.sort
    end
  
    def denormalize_to_higher_roles roles
      ordinary_roles, ordered_roles = split roles
      ordinary_roles.push *higher_roles(lower_role(ordered_roles))
      ordinary_roles.sort
    end
    
    def denormalize_to_lower_roles roles
      ordinary_roles, ordered_roles = split roles
      ordinary_roles.push *lower_roles(higher_role(ordered_roles))
      ordinary_roles.sort
    end
    
    def higher_role roles
      ORDERED_ROLES.each do |role|
        return role if roles.include? role
      end
      nil
    end
    
    def lower_role roles
      ORDERED_ROLES.reverse.each do |role|
        return role if roles.include? role
      end
      nil
    end
    
    def major_roles roles
      major_roles = roles.select{|role| !SYSTEM_ROLES.include?(role)}
      if higher_role = higher_role(roles)
        major_roles << higher_role
      end
      major_roles.sort
    end
  
    def minor_roles roles
      minor_roles = roles.select{|role| !SYSTEM_ROLES.include?(role)}
      if lower_role = lower_role(roles)
        minor_roles << lower_role
      end
      minor_roles.sort
    end
  
    protected
      def split roles
        ordinary_roles = []
        ordered_roles = []

        roles.collect do |role| 
          if ORDERED_ROLES.include? role
            ordered_roles << role
          else
            ordinary_roles << role
          end
        end
      
        [ordinary_roles, ordered_roles]
      end
  
      def lower_roles role
        return [] if role.nil?
        
        role.should! :be_in, ORDERED_ROLES
        index = ORDERED_ROLES.index role
        ORDERED_ROLES[index..-1]
      end

      def higher_roles role
        return [] if role.nil?
        
        role.should! :be_in, ORDERED_ROLES
        index = ORDERED_ROLES.index role
        ORDERED_ROLES[0..index]
      end      
  end
end