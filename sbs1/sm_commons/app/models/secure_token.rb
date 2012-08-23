class SecureToken
  include MongoMapper::Document
  
  connect_to_global_database!
  
  key :_type, String
  
  key :values, Hash
  key :token, String, :default => lambda{String.secure_token}
  key :expires_at, Time, :default => lambda{30.minutes.from_now}
  timestamps!
  
  validates_presence_of :token, :expires_at
  
  def expired?
    expires_at >= Time.now.utc
  end
  
  ensure_index :token, :unique => true
  ensure_index :expires_at
  ensure_index :user_id
  
  def self.by_token token
    return nil if token.blank?
    first :token => token, :expires_at.gte => Time.now.utc
  end
  
  def self.by_token! token
    return by_token(token) || raise(MongoMapper::DocumentNotFound)
  end
end