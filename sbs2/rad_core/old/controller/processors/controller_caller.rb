rad.controller

class ControllerCaller < Rad::Conveyors::Processor
  def call
    # prepare
    response = workspace.response.must.be_defined
    klass = workspace.class.must.be_present
    raise "The controller class #{klass} must be a Rad::Controller::Abstract!" unless klass.is? Rad::Controller::Abstract
    action_name = workspace.action_name = workspace.method_name
    format = workspace.params.format

    # call
    controller = workspace.controller = klass.new
    controller.set! params: workspace.params, action_name: workspace.action_name
    workspace.content = controller.call action_name
  end

end