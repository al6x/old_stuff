module Rad::Controller::Abstract::Miscellaneous
  #
  # respond_to
  #
  def respond_to &block
    @_responder.must.be_nil
    @_responder = Rad::Controller::Abstract::Responder.new
    block.call @_responder
    handler = @_responder.handlers[params.format]
    raise "can't respond to '#{params.format}' format!" unless handler
    handler.call
  end

  module ClassMethods
    #
    # filter_parameter_logging
    #
    inheritable_accessor :filter_parameter_logging, []
    def filter_parameter_logging_with_sugar *parameters
      if parameters.empty?
        filter_parameter_logging_without_sugar
      else
        filter_parameter_logging_without_sugar.push *parameters.collect(&:to_s)
      end
    end
  end
end