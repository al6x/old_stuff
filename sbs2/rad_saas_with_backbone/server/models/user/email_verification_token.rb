class Models::User::EmailVerificationToken < Models::Token
  inherit Models::EmailAttribute
  assign :email, String, true

  validates_presence_of :email

  validate do |token|
    token.errors.add :email, t(:not_unique_email) unless Models::User.by_email(token.email).blank?
  end

  profile :public, only: [:email, :errors]
end