class ForgotPasswordToken < SecureToken
  connect_to_global_database

  key :user_id, ObjectId, :required => true
  belongs_to :user

  after_create do |token|
    Multitenant::UserMailer.deliver_forgot_password token
  end
end