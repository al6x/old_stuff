module Models::User::Authorization
  inherited do
    validate do |user|
      user.errors.add :base, "Anonymous can't have any role!" if user.anonymous? and !user.roles.blank?
    end

    validates_exclusion_of :name, in: %w(admin manager member user anonymous registered)

    before_create :initialize_authorization_attrs

    # We need to change roles if user name updated.
    alias_method :name_without_authorization=, :name=
    define_method :name= do |name|
      self.name_without_authorization = name
      roles.update_user_name self.name
      name
    end
  end

  module ClassMethods
    def anonymous
      Models::User.by_name('anonymous') || raise("You probably don't create Anonymous User!")
    end
  end

  # Roles.

  def member_of_spaces; @member_of_spaces ||= [] end
  def manager_of_spaces; @manager_of_spaces ||= [] end
  def admin_of_accounts; @admin_of_accounts ||= [] end

  def roles
    _cache[:roles] ||= Models::User::Roles.new self
  end

  def role; roles.major.reject{|role| role =~ /^user:/}.first end

  def has_role? role; roles.include? role end

  def anonymous?; name == 'anonymous' end

  def registered?; !anonymous? end

  %w(admin manager member user).each do |role|
    define_method("#{role}?"){roles.include? role}
  end

  # Permissions.

  def permissions
    _cache[:permissions] ||= calculate_permissions_for roles
  end

  def owner_permissions
    _cache[:owner_permissions] ||= calculate_permissions_for ['owner']
  end

  def can? operation, obj = nil
    permissions.include? operation.to_s
  end

  def self.default_permissions
    @default_permissions ||= YAML.load_file("#{__FILE__.dirname}/default_permissions.yml").freeze
  end

  protected
    def initialize_authorization_attrs
      roles
      member_of_spaces
      manager_of_spaces
      admin_of_accounts
    end

    def calculate_permissions_for roles
      permissions = rad.space? ? rad.space.permissions : Models::User::Authorization.default_permissions
      allowed = []
      permissions.each do |operation, allowed_roles|
        allowed << operation if roles.any?{|role| allowed_roles.include? role}
      end
      allowed
    end
end