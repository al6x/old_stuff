rad.conveyors

class ConveyorLogger < Rad::Conveyors::Processor
  def call
    begin
      start_time = Time.now
      next_processor.call

      # if workspace.trace?
      #   total_time = workspace.trace.inject(0){|memo, pair| memo += pair.last}
      #   max_pair = workspace.trace.max_by{|pair| pair.last}
      #   logger.info "Completed in #{(total_time * 1000).round} ms (#{(max_pair.last * 1000).round} ms taken by #{max_pair.first})\n\n"
      # else
      logger.info "RAD completed in #{((Time.now - start_time) * 1000).round} ms\n"
      # end
    rescue StandardError => e
      raise e if rad.test?

      logger.error e
      logger.info "\n"
    end
  end
end