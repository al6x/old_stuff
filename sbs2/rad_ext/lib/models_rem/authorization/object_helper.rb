module Models::Authorization::ObjectHelper
  inherited do
    before_create :owner_name
    validates_presence_of :owner_name

    before_create :viewers
    validate :validate_viewers
    validate :validate_collaborators
  end

  # Owner.

  def owner
    return nil if owner_name.blank?
    _cache[:owner] ||= Models::User.by_name!(owner_name)
  end

  def owner= user
    self.owner_name = user.name
    _cache[:owner] = user
    user
  end

  def owner_name
    @owner_name ||= rad.user? ? rad.user.name : nil
  end

  def owner_name= name
    @owner_name = name
    viewers.update_owner_name name

    _cache.clear
    owner_name
  end

  # Viewers and Collaborators.

  def viewers
    @viewers ||= Models::Authorization.default_viewers
    _cache[:viewers] ||= Models::Authorization::Viewers.new(self, @viewers)
  end

  def collaborators
    @collaborators ||= []
    _cache[:collaborators] ||= Models::Authorization::Collaborators.new(self, @collaborators)
  end

  # Special Permissions.

  def able_view? user
    (owner_name.present? and user.name == owner_name) or
      user.roles.any?{|role| viewers.include? role}
  end

  def able_update? user
    (owner_name.present? and user.name == owner_name) or
      user.roles.any?{|role| collaborators.with_all_higher_roles.include? role}
  end

  protected
    delegate :validate_viewers, to: :viewers
    delegate :validate_collaborators, to: :collaborators
end