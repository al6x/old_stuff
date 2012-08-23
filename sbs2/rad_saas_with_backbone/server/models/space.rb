class Models::Space
  inherit Mongo::Model, Models::TextProcessor

  def initialize *args
    super *args

    self._id = generate_id
    self.default_url = '/'
    self.language = rad.locale? ? rad.locale.current : 'en'
    self.theme = 'default'
    self.default = false
  end

  profile :public,
    only: [:name, :title, :default_url, :language, :bottom_text, :theme, :logo_url, :default] do |r|
    r[:id] = name
  end

  profile :protected,
    only: [:name, :title, :default_url, :language, :bottom_text, :theme, :logo_url, :default] do |r|
    r[:id] = name
  end

  # Account.

  def account= account
    self._parent = account
  end
  def account; _parent || raise("account not defined!") end
  validates_presence_of :account

  # Copying some errors from Account.
  after_validate do |space|
    unless (base_errors = space.account.errors[:base]).blank?
      space.errors.add :base, base_errors
    end

    unless (spaces_errors = space.account.errors[:spaces]).blank?
      space.errors.add :base, spaces_errors
    end
  end

  # Permissions.

  def permissions
    Models::User::Authorization.default_permissions
  end

  # Attributes.

  attr_accessor :name
  assign :name, String, true
  validates_presence_of :name
  validates_format_of :name, with: /\A[a-z][a-z\-0-9]*[a-z0-9]\Z/
  validate do |space|
    # Validating for unique name between other account's spaces.
    if space.account.spaces.any?{|s| s.name == space.name and !s.equal?(space)}
      space.errors.add :name, 'not unique!'
    end
  end

  attr_reader :default
  def default?; default end
  def default= value
    if value
      # Removing defsult from any other space.
      account.spaces.each do |space|
        space.default = false unless space == self
      end
    end
    @default = value
  end
  assign :default, Boolean, true

  attr_accessor :title
  assign :title, String, true

  attr_writer :default_url
  assign :default_url, String, true

  attr_accessor :language
  assign :language, String, true

  include Models::TextProcessor
  attr_accessor :bottom_text
  available_as_markup :bottom_text
  assign :original_bottom_text, String, true

  attr_accessor :theme
  assign :theme, String, true

  attr_accessor :logo_url
  assign :logo_url, String, true

  timestamps!

  def to_param; name end
end