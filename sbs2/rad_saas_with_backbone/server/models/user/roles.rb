class Models::User::Roles
  include Enumerable

  def initialize user
    @user, @cache = user, {}

    @roles = []
    roles << (user.anonymous? ? 'anonymous' : 'registered')
    roles.push 'user', "user:#{user.name}"

    # Some roles depends on current space and account.
    if rad.account?
      account = rad.account
      roles << 'admin' if user.admin_of_accounts.include? account._id
    end

    if rad.space?
      space = rad.space
      roles << 'member'  if user.member_of_spaces.include? space._id
      roles << 'manager' if user.manager_of_spaces.include? space._id
    end

    # Global admin.
    roles.push 'member', 'manager', 'admin', 'global_admin' if user.global_admin?

    roles.uniq!
    roles.sort!
  end

  delegate :each, :==, :inspect, :to_a, :to_s, to: :roles

  def include? role; super(role.to_s) end
  alias_method :has?, :include?

  def add role
    role = role.to_sym
    should_be_valid_user_input_role role

    return if user.global_admin?

    space, account = rad.space, rad.account
    if role == :admin
      user.admin_of_accounts.add account._id unless user.admin_of_accounts.include? account._id
      @roles.add 'admin' unless @roles.include? 'admin'
    end
    if role == :admin or role == :manager
      user.manager_of_spaces.add space._id unless user.manager_of_spaces.include? space._id
      @roles.add 'manager' unless @roles.include? 'manager'
    end
    if role == :admin or role == :manager or role == :member
      user.member_of_spaces.add space._id unless user.member_of_spaces.include? space._id
      @roles.add 'member' unless @roles.include? 'member'
    end

    roles.sort!
    cache.clear
    role
  end

  def delete role
    role = role.to_sym
    should_be_valid_user_input_role role

    return if user.global_admin?

    space, account = rad.space, rad.account
    if role == :member or role == :manager or role == :admin
      user.admin_of_accounts.delete account._id
      @roles.delete 'admin'
    end
    if role == :member or role == :manager
      user.manager_of_spaces.delete space._id
      @roles.delete 'manager'
    end
    if role == :member
      user.member_of_spaces.delete space._id
      @roles.delete 'member'
    end

    roles.sort!
    cache.clear
    role
  end

  def major
    cache[:major] ||= [
      "user:#{user.name}",
      %w(admin manager member user).find{|role| roles.include? role}
    ].sort
  end

  def update_user_name name
    roles.delete_if{|role| role =~ /^user:/}
    roles << "user:#{name}"
    roles.sort!
    cache.clear
  end

  def to_rson options = {}
    to_a
  end

  # Handy methods for checking roles.
  %w(admin manager member user anonymous registered).each do |role|
    define_method("#{role}?"){include? role}
  end

  protected
    attr_reader :user, :roles, :cache

    def should_be_valid_user_input_role role
      role.must.be_in [:admin, :manager, :member, :user]
    end
end