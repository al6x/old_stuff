Exception.class_eval do
  alias_method :set_backtrace_without_filter, :set_backtrace
  def set_backtrace array
    begin
      if environment = rad.environment? && rad.environment
        set_backtrace_without_filter array.sfilter(environment.backtrace_filters)
      else
        set_backtrace_without_filter array
      end
    rescue
      set_backtrace_without_filter array
    end
  end
end