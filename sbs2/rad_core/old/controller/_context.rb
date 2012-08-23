class Rad::Controller::Context < Rad::Template::Context
  attr_reader :controller, :controller_name, :action_name
  delegate :params, :request, :response, to: :controller

  def initialize instance_variables, controller
    super instance_variables
    @controller = controller
  end
end