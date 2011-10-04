class UserError < StandardError
end

Object.class_eval do
  def raise_user_error msg
    raise UserError, msg
  end

  def self.raise_user_error msg
    raise UserError, msg
  end
end