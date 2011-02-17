class Space
  include MongoMapper::Document
  
  # 
  # Multitenant
  # 
  connect_to_global_database!
  

  key :name, String, :protected => true
  key :title, String
  key :account_id, ObjectId, :protected => true
  
  timestamps!
  
  
  # 
  # Indexes
  # 
  ensure_index :name
  ensure_index :account_id
  
  
  def default?; name == 'default' end
  def self.default? name; name == 'default' end

  
  belongs_to :account
  
  validates_presence_of :name, :account
  validates_uniqueness_of :name, :scope => :account_id
  validates_format_of :name, :with => STRONG_NAME
  
  def self.current= space
    Thread.current['current_space'] = space
  end

  def self.current
    Thread.current['current_space'].should_not! :be_nil
  end
  
  def self.current?
    !!Thread.current['current_space']
  end
  
  # 
  # Validation
  # 
  validate :validate_default
  def validate_default
    errors.add :base, t(:forbiden_to_change_default_space) if name_changed? and name_was == 'default'
  end
  protected :validate_default 
  
  
  #
  # Roles and Permissions
  #
  key :custom_roles, Array
  def custom_roles_as_string
    custom_roles.join("\n")
  end
  def custom_roles_as_string= str
    self.custom_roles = str.strip.split("\n")
  end
    
  SPECIAL_PERMISSIONS = {
    'global_administration' => ['admin'],
    'account_administration' => ['admin'],
    'view' => ['owner', 'manager']
  }
   
  def permissions
    self.class.permissions
  end
  
  @@permissions = nil
  def self.permissions
    unless @@permissions
     @@permissions = YAML.load_file("#{File.dirname __FILE__}/default_permissions.yml")
     @@permissions.merge!(SPECIAL_PERMISSIONS)
    end
    @@permissions
  end
  
  
  # 
  # Links
  # 
  key :default_url, String
  key :menu, Array
  
  def menu_as_string
    menu.to_a.collect{|name, url| "#{name}:#{url}"}.join("\n") 
  end
  
  def menu_as_string=(str)
    self.menu = []
    lines = str.split("\n") 
    lines.each do |line|
      name, url = line.split(':').collect(&:strip)
      menu << [name, url] unless name.blank? or url.blank?
    end
  end
  
  
  # 
  # Language
  # 
  AVAILABLE_LANGUAGES = %w{en ru}
  key :language, String, :default => SETTING.default_language('en')
  
  
  # 
  # Files audit
  #   
  key :max_user_files_size, Integer, :default => 0
  
  
  # 
  # Other
  #
  plugin MongoMapper::Plugins::TextProcessor 
  markup_key :bottom_text
  
  
  # 
  # Theme support
  # 
  key :theme, String, :default => 'default'
  def self.available_themes
    SETTING.available_themes(['default'])
  end  
  validates_inclusion_of :theme, :within => Space.available_themes
  
  include Paperclip
  has_attached_file :logo  
  validates_maximum_file_size :logo
  
  def slug; name end
  
  
  # 
  # Wigets
  # 
  # has_many :resources #, :dependent => :destroy
  # has_many :votes #, :dependent => :destroy
  
  
  # def self.account_inheritable_key key, type, options = {}
  #   key = key.to_s
  #   
  #   self.key key, type, options
  #   Account.send :key, key, type, options
  #   
  #   define_method key do
  #     unless merged_value = cache[key]
  #       account_value = account.send akey
  #       value = send(key)
  #       merged_value = merge account_value, value
  #       cache[key] = merged_value
  #     end
  #     merged_value
  #   end
  # end
  # 
  # protected
  #   def self.merge parent_value, value
  #     return value || parent_value if value.nil? or parent_value.nil?
  #     
  #     if parent_value.is_a? Hash
  #       parent_value.merge(value)
  #     elsif parent_value.is_a? Array
  #       (parent_value + value).uniq
  #     else
  #       value
  #     end
  #   end
end