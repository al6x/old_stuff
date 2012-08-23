module Models::User::Authentication
  DIGEST_STRETCHES = 10
  PASSWORD_LENGTH = 3..40

  attr_accessor :crypted_password, :salt

  def password; @_password end
  def password= password
    @_password = password
    encrypt_password!
  end

  inherited do
    validates_presence_of :crypted_password
    validates_confirmation_of :password, if: :validate_password?
    validates_length_of :password, in: PASSWORD_LENGTH, if: :validate_password?
  end

  def authenticated_by_password? password
    return false if crypted_password.blank? or password.blank? or anonymous? or !active?
    self.crypted_password == self.class.encrypt_password(password, salt)
  end

  def update_password old_password, password, password_confirmation
    if crypted_password.blank?
      self.password, self.password_confirmation = password, password_confirmation
    elsif authenticated_by_password? old_password
      self.password, self.password_confirmation = password, password_confirmation
      true
    else
      errors.add :base, t(:invalid_old_password)
      false
    end
  end

  protected
    def encrypt_password!
      if password.blank?
        self.crypted_password = ""
      else
        self.salt ||= self.class.generate_token
        self.crypted_password = self.class.encrypt_password password, salt
      end
    end

    def validate_password?
      !password.nil?
      # crypted_password.blank? or !password.blank?
    end

  module ClassMethods
    def authenticate_by_password name, password
      return nil if name.blank? or password.blank?
      u = Models::User.first state: 'active', name: name
      u && u.authenticated_by_password?(password) ? u : nil
    end

    # def by_secure_token token
    #   first conditions: {
    #     secure_token: token,
    #     secure_token_expires_at: {:$gt => Time.now.utc}
    #   }
    # end

    def encrypt_password password, salt
      digest = rad.saas.site_key
      DIGEST_STRETCHES.times do
        digest = secure_digest(digest, salt, password, rad.saas.site_key)
      end
      digest
    end

    def generate_token
      secure_digest Time.now, (1..10).map{ rand.to_s }
    end

    protected
      def secure_digest *args
        Digest::SHA1.hexdigest(args.flatten.join('--'))
      end
  end
end