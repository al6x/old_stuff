class Models::Account
  inherit Mongo::Model
  collection :accounts

  def initialize *args
    super *args

    self.enabled = true

    space = Models::Space.new
    space.account = self
    space.set name: 'default', default: true

    spaces << space
  end

  profile :public,
    only: [:name],
    methods: [:spaces] do |r|
    r[:id] = name
  end

  profile :protected,
    methods: [:domains, :spaces] do |r|
    r[:id] = name
  end

  # Name.
  attr_accessor :name
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_length_of :name, in: 2..20
  validates_format_of :name, with: /\A[a-z][a-z\-0-9]*[a-z0-9]\Z/
  validates_exclusion_of :name, in: %w{global}
  assign :name, String, true

  # Form helper.
  def new_name= name
    self.name = name
  end
  assign :new_name, String, true

  # Enabled.
  attr_accessor :enabled
  def enabled?; !!enabled end
  assign :enabled, Boolean, true

  # Domains.

  attr_writer :domains
  def domains; @domains ||= [] end
  available_as_string :domains, :column
  assign :domains_as_string, String, true

  # Adding default domain.
  before_validate do |model|
    domain = "#{model.name}.#{rad.http.host}"
    model.domains.add domain unless model.domains.include? domain
  end


  # Spaces.

  def spaces; @spaces ||= [] end
  embedded :spaces

  before_save do |account|
    account.spaces.sort!{|a, b| a.name <=> b.name}
  end

  def default_space
    spaces.find{|space| space.default?}
  end

  def get_space name
    spaces.find{|space| space.name == name}
  end

  # Miscellaneous.

  attr_accessor :web_analytics_token

  timestamps!

  def to_param; name end

  class << self
    def default_account
      Account.by_name 'default'
    end
    cache_method_with_params_in_production :default_account
  end
end