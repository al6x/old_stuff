class Models::User
  inherit Mongo::Model
  collection :users

  profile :public,
    only: [:name, :first_name, :last_name],
    methods: [:role, :roles] do |r|
    r[:id] = name
  end

  profile :public_full,
    only: [:name, :first_name, :last_name],
    methods: [:role, :roles, :permissions, :owner_permissions] do |r|
    r[:id] = name
  end


  # Name.
  attr_reader :name
  def name= value;
    @name = value.try :downcase
    self._id = @name
  end
  validates_presence_of :name
  validates_length_of :name, in: 4..40
  validates_uniqueness_of :name, if: :new?
  validates_format_of :name, with: /\A[a-z_][a-z_0-9]*\Z/

  # Email.
  inherit Models::EmailAttribute
  validates_uniqueness_of :email
  validates_presence_of :email
  assign :email, String, true

  # Timestamps.
  timestamps!

  # State.
  attr_writer :state
  def state; @state ||= 'inactive' end
  def activate; self.state = 'active' end
  def active?; state == 'active' end
  def deactivate; self.state = 'inactive' end
  def inactive?; state == 'inactive' end
  validates_presence_of :state

  # Autentication.
  inherit Models::User::Authentication

  # Authorization.
  inherit Models::User::Authorization

  # Avatar
  # def self.avatar_url user_name
  #   "#{rad.users.avatars_path}/avatars/#{user_name}.icon"
  # end

  # Profile.
  attr_accessor :first_name, :last_name
  assign do
    first_name String, true
    last_name  String, true
  end

  # Miscellaneous
  def to_param; name end
  # def dom_id; "user_#{name}" end
  # def slug; name end

  # Global admin.
  attr_accessor :global_admin
  def global_admin?; !!global_admin end
end