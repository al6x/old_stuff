class NilClass
  def blank?; true end

  def to_openobject deep = false
    OpenObject.new
  end
  alias_method :to_oo, :to_openobject
end