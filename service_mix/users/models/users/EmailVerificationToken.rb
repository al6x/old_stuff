class EmailVerificationToken < SecureToken
  connect_to_global_database

  key :email, :required => true
  
  EMAIL_NAME_REGEX  = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.)+'.freeze
  DOMAIN_TLD_REGEX  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  EMAIL_REGEX       = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i

  validates_length_of :email, :within => 6..100
  validates_format_of :email, :with => EMAIL_REGEX
  
  validate do |token|
    token.errors.add :email, t(:not_unique_email) unless User.find_by_email(token.email).blank?
  end
  

  after_create do |token|
    Multitenant::UserMailer.deliver_email_verification token
  end
end