class Models::UserStub
  inherit Models::Authorization::UserHelper
  include RubyExt::OpenConstructor

  attr_accessor :name

  def roles; @roles ||= [] end
  def permissions; @permissions ||= {} end
  def owner_permissions; @owner_permissions ||= {} end
  attr_writer :roles, :permissions, :owner_permissions

  def _cache; @_cache ||= {} end
end