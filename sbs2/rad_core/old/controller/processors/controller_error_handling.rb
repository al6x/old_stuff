rad.controller

class ControllerErrorHandling < Rad::Conveyors::Processor
  def call
    workspace.response.must.be_defined

    begin
      next_processor.call
    rescue StandardError => e
      if rad.test?
        # e.set_backtrace e.backtrace.sfilter(Exception.filters)
        raise e
      elsif rad.production?
        error_shown_to_user = StandardError.new "Internal error!"
        error_shown_to_user.set_backtrace []
      else
        error_shown_to_user = e
      end

      workspace.response.clear if workspace.response
      format = workspace.params.format
      handler = SPECIAL_ERROR_HANDLERS[format] || DEFAULT_ERROR_HANDLER
      workspace.content = handler.call error_shown_to_user, format


      logger.error e
      logger.info "\n"
    end
  end

  SPECIAL_ERROR_HANDLERS = {
    'json' => lambda{|e, format|
      {error: e.message}.to_json
    }
  }

  DEFAULT_ERROR_HANDLER = lambda{|e, format|
    tname = rad.controller.send("#{rad.mode}_error_template")
    if tname and rad.template.exist?(tname, format: format, exact_format: true)
      data = rad.template.render(tname,
        format: format,
        locals: {error: e}
      )
    else
      e.message
    end
  }
end