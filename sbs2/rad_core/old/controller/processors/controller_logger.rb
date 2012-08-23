rad.controller

class ControllerLogger < Rad::Conveyors::Processor
  def call
    if (klass = workspace.class) and (method = workspace.method_name)
      logger.info "RAD processing #{klass.name}.#{method} with #{workspace.params.inspect}"
    end
    next_processor.call
  end
end