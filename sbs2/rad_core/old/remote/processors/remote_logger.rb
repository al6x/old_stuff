rad.remote

class RemoteLogger < Rad::Conveyors::Processor
  def call
    next_processor.call

    if (klass = workspace.class) and (method = workspace.method_name)
      logger.info "RAD processing #{klass.name}.#{method} with #{workspace.params.inspect}"
    end
  end
end