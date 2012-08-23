module Models::EmailAttribute
  EMAIL_NAME_REGEX  = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.?)+'.freeze
  DOMAIN_TLD_REGEX  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|)'.freeze
  EMAIL_REGEX       = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i

  inherited do
    validates_length_of :email, in: 6..100, allow_blank: true
    validates_format_of :email, with: EMAIL_REGEX, allow_blank: true
  end

  attr_reader :email
  def email= value
    @email = value.try :downcase
  end
end