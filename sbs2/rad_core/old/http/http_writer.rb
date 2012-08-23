rad.http

class HttpWriter < Rad::Conveyors::Processor
  def call
    response = workspace.response.must.be_defined

    begin
      next_processor.call

      response.body = workspace.content if response.body.blank? and workspace.content?
      response.content_type ||= Mime[(workspace.params.format if workspace.params?) || rad.http.default_format]
    rescue StandardError => e
      raise e if rad.test?

      response.clear
      if workspace.params.format? and workspace.params.format == 'json'
        response.body = {error: (rad.production? ? "Internal error!" : e.message)}.to_json
        response.content_type = Mime.json
      else
        response.body = (rad.production? ? "Internal error!" : e.message)
        response.content_type = Mime.text
      end

      logger.error e
      logger.info "\n"
    end
  end
end