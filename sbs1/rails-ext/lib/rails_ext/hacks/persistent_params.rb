# By default Rails optimizes named routes and doesn't adds default_url_options, so we fix this.
ActionController::Base.send :helper_method, :default_url_options

ActionController::Routing::Optimisation::PositionalArguments.send :class_eval do
  def guard_conditions_with_def_url_opt
    guard_conditions_without_def_url_opt << "default_url_options(nil).blank?"
  end
  alias_method_chain :guard_conditions, :def_url_opt
end

ActionController::Routing::Optimisation::PositionalArgumentsWithAdditionalParams.send :class_eval do
  def guard_conditions_with_def_url_opt
    guard_conditions_without_def_url_opt << "default_url_options(nil).blank?"
  end
  alias_method_chain :guard_conditions, :def_url_opt
end