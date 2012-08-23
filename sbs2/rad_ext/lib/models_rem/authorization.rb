module Models::Authorization
  ORDERED_ROLES = %w(admin manager member user).freeze
  SYSTEM_ROLES = (ORDERED_ROLES + %w(anonymous registered)).sort.freeze
  PRESERVED_USER_NAMES = SYSTEM_ROLES

  class << self
    def with_all_higher_roles roles
      list = roles.clone
      list.push *%w(admin) if roles.include? 'manager'
      list.push *%w(admin manager) if roles.include? 'member'
      list.push *%w(admin manager member) if roles.include? 'user'
      list.uniq!
      list.sort!
      list
    end

    def with_all_lower_roles roles
      list = roles.clone
      list.push *%w(user) if roles.include? 'member'
      list.push *%w(user member) if roles.include? 'manager'
      list.push *%w(user member manager) if roles.include? 'admin'
      list.uniq!
      list.sort!
      list
    end

    def major_roles roles
      list = roles.reject{|role| SYSTEM_ROLES.include?(role)}
      ORDERED_ROLES.each do |role|
        if roles.include? role
          list << role
          break
        end
      end
      list.sort!
      list
    end

    def minor_roles roles
      list = roles.reject{|role| SYSTEM_ROLES.include?(role)}
      ORDERED_ROLES.reverse.each do |role|
        if roles.include? role
          list << role
          break
        end
      end
      list.sort!
      list
    end

    def default_viewers
      (
        (rad.user? ? ['admin', 'manager', "user:#{rad.user.name}"] : ['admin', 'manager']) +
        Array.wrap(rad.config.default_viewers)
      ).uniq.sort
    end

    def should_be_valid_user_input_role role
      role.must.be_in %w(member user)
    end

    def anonymous? name; name == 'anonymous' end
  end
end