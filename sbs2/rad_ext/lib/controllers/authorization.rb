module Controllers::Authorization
  module ClassMethods
    def require_permission operation, *args, &block
      method = :"require_permission_#{operation}"
      define_method method do
        require_permission(operation, (block && block.call(self)))
      end
      before method, *args
    end
  end

  protected
    inject :user

    def can? *args
      user.can? *args
    end

    def owner? *args
      user.owner? *args
    end

    def registered_user_required
      access_denied! unless user.registered?
    end

    def anonymous_user_required
      access_denied! if user.registered?
    end

    def require_permission *args
      access_denied! unless user.can? *args
    end

    def access_denied!
      raise UserError, t(:access_denied)
    end
end