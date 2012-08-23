class Models::Token
  inherit Mongo::Model
  collection :tokens

  def [] k
    instance_variable_get :"@#{k}"
  end
  def []= k, v
    instance_variable_set :"@#{k}", v
  end

  attr_writer :token
  def token; @token ||= rad.cipher.generate_token end
  validates_presence_of :token

  attr_writer :expires_at
  def expires_at; @expires_at ||= Time.now + 30 * 60 * 60 end
  validates_presence_of :expires_at

  def expired?
    expires_at >= Time.now.utc
  end

  timestamps!

  class << self
    def by_token token
      return nil if token.blank?
      first token: token, expires_at: {_gte: Time.now.utc}
    end
    alias_method :first_by_token, :by_token

    def by_token! token
      return by_token(token) || raise(Mongo::NotFound, "token #{token} not found!")
    end
    alias_method :first_by_token!, :by_token!
  end
end