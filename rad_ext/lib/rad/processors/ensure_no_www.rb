# enshure domain has no www. except if there's custom subdomain
class EnsureNoWww < Conveyors::Processor
  def call
    workspace.params.must_be.defined
    if workspace.params.format == 'html' and url_with_www?
      redirect_without_www
    else
      next_processor.call
    end
  end            
  
  protected
    def uri
      @uri ||= Uri.parse workspace.request.url
    end
  
    def url_with_www?
      uri.host =~ /^www\./
    end
    
    def redirect_without_www
      uri.host = uri.host.sub(/^www\./, '')
      url = uri.to_s
      
      response = workspace.response
      response.status = 301
      response.headers['Location'] = url
      response.body = %(<html><body>You are being <a href="#{url.html_escape}">redirected</a>.</body></html>)
    end
end