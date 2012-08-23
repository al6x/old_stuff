rad.remote

class RemoteCaller < Rad::Conveyors::Processor
  # TODO2 :remote isn't registered with rad[
  inject :remote

  def initialize next_processor, result_variable = 'content'
    super(next_processor)
    @result_variable = result_variable
  end

  def call
    return next_processor.call unless workspace.class?

    # prepare
    klass = workspace.class
    raise "The remote class #{klass} must be a Rad::Remote::RemoteController!" unless klass.is? Rad::Remote::RemoteController
    workspace.remote_object = klass.new
    method = workspace.method_name

    # call
    begin
      result = workspace.remote_object.run_callbacks :action, method: method do
        workspace.remote_object.send method
      end

      ensure_correct_result! result
      workspace.remote_result = result

      next_processor.call

      # write JSON as a result if format is JSON and no one else filled it
      if workspace[@result_variable].blank?
        workspace[@result_variable] = workspace.remote_result.to_json
      end
    rescue StandardError => e
      raise e if !workspace.params.format == 'json' or rad.test?

      workspace[@result_variable] = {error: e.message}.to_json

      logger.error e
      logger.info "\n"
    end
  end

  private
    def ensure_correct_result! result
      unless result.rson?
        raise "You can't use object of type '#{result.class}' as Remote's return value!"
      end
    end
end