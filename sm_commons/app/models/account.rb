class Account
  include MongoMapper::Document
  
  # 
  # Multitenant
  # 
  connect_to_global_database!
  
  
  key :name, String, :protected => true
  key :title, String
  key :domains, Array, :protected => true
  key :web_analytics_js, String # Add JS Injection Protection TODO1
  
  timestamps!
  
  
  # 
  # Indexes
  # 
  ensure_index :name, :unique => true
  ensure_index :domains
  
  # 
  # Validations
  # 
  validates_presence_of :name
  validates_length_of :name, :within => 2..20
  validates_format_of :name, :with => /\A[a-z][a-z\-0-9]*[a-z0-9]\Z/
  validates_exclusion_of :name, :within => %w{global}
  
  
  # 
  # Form helpers
  # 
  def domains_as_string
    domains.join("\n")
  end
  
  def domains_as_string= str
    self.domains = str.split("\n") unless str.nil?    
  end
  
  many :spaces
  
  before_validation :create_default_subdomain
  def create_default_subdomain
    default_subdomain = "#{name}.#{SETTING.master_domain!}"
    self.domains << default_subdomain unless name.blank? or domains.include?(default_subdomain)
  end
  protected :create_default_subdomain
  
  after_create :create_default_space
  def create_default_space
    space = spaces.build
    space.name = 'default'
    space.save!
  end
  protected :create_default_space

  def self.current= account
    Thread.current['current_account'] = account
  end

  def self.current
    Thread.current['current_account'].should_not! :be_nil
  end
  
  def self.current?
    !!Thread.current['current_account']
  end
  
  def select account_name, space_name = 'default'
    Account.current = Account.find_by_name! account_name
    Space.current = Account.current.spaces.find_by_name! space_name
  end
  
  # 
  # Files Audit
  # 
  key :files_size, Integer, :default => 0, :protected => true
  key :max_file_size, Integer, :default => SETTING.max_file_size!    
  key :max_account_files_size, Integer, :default => SETTING.max_account_files_size!
end