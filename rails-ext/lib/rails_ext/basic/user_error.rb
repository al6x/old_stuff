class UserError < RuntimeError
end

Object.send :class_eval do
  def raise_user_error msg
    raise UserError, msg
  end

  def self.raise_user_error msg
    raise UserError, msg
  end
end