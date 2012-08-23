class Analytics
  def initialize app
    @app = app
  end

  def call env
    begin
      request = Rad::Http::Request.new env
      Models::Domain.hit! request.normalized_domain unless request.xhr?
    rescue StandardError => e
      rad.logger.error e
    end

    @app.call env
  end
end