module MongoMapper
  module Plugins
    module PasswordAuthentication
      SITE_KEY = '3eed5a60c1bf8d43de5d0560e9fc2442fe74fdad'
      DIGEST_STRETCHES = 10
      PASSWORD_LENGTH = 3..40
      
      
      module InstanceMethods            
        def authenticated_by_password? password
          return false if crypted_password.blank? or password.blank?
          self.crypted_password == self.class.encrypt_password(password, salt)
        end
    
        # def reset_password password, password_confirmation
        #   self.password, self.password_confirmation = password, password_confirmation
        #   self.secure_token = nil
        # end
    
        def update_password password, password_confirmation, old_password
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

        # def update_password password, confirmation
        #   self.password, self.password_confirmation = password, confirmation
        #   encrypt_password
        # end
        # 
        # def generate_secure_token!
        #   self.secure_token = AuthStrategy.generate_token
        #   self.secure_token_expires_at = AuthStrategy::SECURE_TOKEN_EXPIRATION.from_now
        # end
        # 
        # def clear_secure_token!
        #   self.secure_token = nil
        #   self.secure_token_expires_at = nil
        # end
        # 
        # def forgot_password
        #   generate_secure_token!
        #   UserStatusMailer.deliver_forgot_password self
        # end
        
        def password= password
          @password = password
          encrypt_password!
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
      end
    
      module ClassMethods
        def acts_as_authenticated_by_password!
          key :crypted_password, String, :protected => true
          key :salt, String, :protected => true
        
          attr_reader :password
          validates_confirmation_of :password, :if => :validate_password?
          validates_length_of :password, :within => PASSWORD_LENGTH, :if => :validate_password?
        end
      
        def authenticate_by_password name, password
          return nil if name.blank? or password.blank?
          u = User.first :conditions => {:state => 'active', :name => name}
          u && u.authenticated_by_password?(password) ? u : nil
        end

        # def by_secure_token token
        #   first :conditions => {
        #     :secure_token => token, 
        #     :secure_token_expires_at => {:$gt => Time.now.utc}
        #   }
        # end
        # 
        # def by_open_id id
        #   return nil if id.blank?
        #   first :open_ids => id
        # end
        
        def encrypt_password password, salt
          digest = SITE_KEY
          DIGEST_STRETCHES.times do
            digest = secure_digest(digest, salt, password, SITE_KEY)
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
  end
end