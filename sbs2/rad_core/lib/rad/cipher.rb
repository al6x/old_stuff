class Rad::Cipher
  # Configuration.
  attr_accessor :secret
  attr_required :secret

  def initialize secret = nil
    @secret = secret
  end

  def hmac data
    require 'openssl'
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
  end

  def sign data
    "#{data}--#{hmac(data)}"
  end

  def unsign signed_data
    data, signature = signed_data.rsplit '--', 2
    raise "invalid signature" unless signature == hmac(data)
    data
  end

  def encrypt data
    cipher = new_cipher
    iv = cipher.random_iv

    cipher.encrypt
    cipher.key = secret
    cipher.iv  = iv

    encrypted_data = cipher.update(data)
    encrypted_data << cipher.final

    "#{encrypted_data}--#{iv}"
  end

  def decrypt data
    cipher = new_cipher
    encrypted_data, iv = data.rsplit '--', 2

    cipher.decrypt
    cipher.key = secret
    cipher.iv  = iv

    decrypted_data = cipher.update(encrypted_data)
    decrypted_data << cipher.final

    decrypted_data
  rescue StandardError
    raise "invalid encryption!"
  end

  def generate_token
    original = [Time.now, (1..10).map{ rand.to_s }]
    Digest::SHA1.hexdigest(original.flatten.join('--'))
  end

  protected
    def new_cipher
      require 'openssl'
      OpenSSL::Cipher::Cipher.new 'aes-256-cbc'
    end
end