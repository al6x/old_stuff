Time.class_eval do
  alias_method :to_s_without_defaults, :to_s
  def to_s
    strftime "%Y-%m-%d %H:%M:%S"
  end
end