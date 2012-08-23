class User
  include MongoMapper::Document

  connect_to_global_database!
  
  set_collection_name 'users'
  
  key :_type, String
  
  key :name, String, :protected => true
  key :email, String, :protected => true
  key :state, String, :protected => true
  timestamps!
  
  def name= value
    # write_attribute :name, (value ? value.downcase : nil)
    super(value ? value.downcase : nil)
  end
  
  def email= value
    # write_attribute :email, (value ? value.downcase : nil)
    super(value ? value.downcase : nil)
  end

  # key :remember_token, String, :protected => true
  # key :remember_token_expires_at, Time, :protected => true
  # key :secure_token, String, :protected => true
  # key :secure_token_expires_at, Time, :protected => true  
  
  # 
  # Validations
  # 
  validates_presence_of :name
  validates_length_of :name, :within => 4..40
  validates_uniqueness_of :name
  validates_format_of :name, :with => STRONG_NAME
  
  EMAIL_NAME_REGEX  = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.)+'.freeze
  DOMAIN_TLD_REGEX  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  EMAIL_REGEX       = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i
  
  validates_length_of :email, :within => 6..100, :allow_blank => true
  validates_uniqueness_of :email, :allow_blank => true
  validates_format_of :email, :with => EMAIL_REGEX, :allow_blank => true
  
  
  # 
  # Indexes
  # 
  ensure_index :name, :unique => true
  ensure_index :email
  # ensure_index :remember_token #, :unique => true
  ensure_index :state
  ensure_index :created_at
  ensure_index :updated_at

  
  #
  # Autentication
  # 
  plugin MongoMapper::Plugins::OpenIdAuthentication
  acts_as_authenticated_by_open_id!
  
  plugin MongoMapper::Plugins::PasswordAuthentication
  acts_as_authenticated_by_password!
  
  def validate_authentication
    if crypted_password.blank? and open_ids.blank?
      errors.add :password, t(:should_not_be_blank)
    end
  end
  protected :validate_authentication
  validate :validate_authentication
  
  
  # 
  # Lifecycle
  # 
  state_machine :state, :initial => :inactive do
  
    # after_transition :on => :wait_for_email_confirmation do |_self, trans|
    #   _self.generate_secure_token!
    #   UserStatusMailer.deliver_signup_notification _self
    # end
  
    # after_transition :on => :activate do |_self, trans|
    #   _self.clear_secure_token!
    #   UserStatusMailer.deliver_activation_notification _self
    # end    
  
    # on :wait_for_email_confirmation do
    #   transition any => :inactive
    # end
    
    on :activate do
      transition all => :active
    end
  
    on :inactivate do
      transition all => :inactive
    end
    
  end


  #
  # Authorization
  #
  plugin MongoMapper::Plugins::SpaceKeys
  plugin MongoMapper::Plugins::Authorized
  acts_as_authorized
  
  
  # 
  # Avatar
  # 
  include Paperclip

  interpolation = "/system/avatars/:name/:filename_with_style"
  # interpolation = "/system/:account/:space/files/:slug/:filename_with_style"
  has_attached_file :avatar, :styles => {:icon => ["50x50#", :png]}, :default_style => :icon,  
    :path => (":rails_root/public" + interpolation),
    :url => (ServiceMix.relative_url_root + interpolation)
  
  validates_maximum_file_size :avatar
    
  def set_avatar_file_name
    if avatar and avatar.instance_read(:file_name) != "image.png"
      self.avatar.instance_write(:file_name, "image.png") 
    end
  end
  protected :set_avatar_file_name
  before_save :set_avatar_file_name
  
  def self.avatar_url user_name
    "#{ServiceMix.relative_url_root}/system/avatars/#{user_name}/image.icon.png?123456789"
  end
  
  
  # 
  # Profile
  # 
  key :first_name, String
  key :last_name, String


  # 
  # Helpers
  #
  class << self 

    def [] name
      find_by_name name.to_s
    end
    
    def current= current
      Thread.current['current_user'] = current
    end

    def current
      Thread.current['current_user'].should_not! :be_nil
    end

    def current?
      Thread.current['current_user'] != nil
    end
    
  end
  
  
  # 
  # Other
  # 
  space_key :files_size, Integer, :default => 0
  def to_param; name end
  validate do |u|
    u.space_keys_containers.size.should! == 0 if u.anonymous?
  end
  
  def slug; name end
end