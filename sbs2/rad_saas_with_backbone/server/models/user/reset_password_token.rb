class Models::User::ResetPasswordToken < Models::Token
  attr_accessor :user_id
  def user
    _cache[:user] ||= Models::User.by_id user_id
  end
  def user= user
    _cache[:user] = user
    self.user_id = user._id
  end
end