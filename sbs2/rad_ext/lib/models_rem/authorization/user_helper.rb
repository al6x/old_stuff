module Models::Authorization::UserHelper
  # Owner.

  def owner_name; anonymous? ? nil : name end

  def owner? object
    object.present? and name.present? and registered? and object.respond_to(:owner_name) == self.name
  end

  # Roles.

  def has_role? role; roles.include? role end

  def anonymous?; Models::Authorization.anonymous?(name) end

  def registered?; !anonymous? end

  # Permisions.

  def can? operation, object = nil
    operation = operation.to_s
    return true if has_role? 'admin'

    custom_method = :"able_#{operation}?"
    return object.send custom_method, self if object.respond_to? custom_method

    !!(permissions[operation] or
      (owner?(object) and owner_permissions[operation]))
  end

  def can_view? object; can? :view, object end
end