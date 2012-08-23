class Rad::Environment
  inherit Rad::Environment::FilesHelper

  attr_writer :backtrace_filters
  def backtrace_filters; @backtrace_filters ||= [] end
end