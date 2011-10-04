module ForgeryProtector
  BROWSER_GENERATED_TYPES = %w(
    text/html
    text/plain
    application/x-www-form-urlencoded
    multipart/form-data    
  ).to_set
  
  BROWSER_GENERATED_FORMATS = %w(html js)
  
  protected
    def protect_from_forgery
      request = workspace.request
      if request.session        
        sat = request.session['authenticity_token']
        content_type = request.content_type
        format = workspace.params.format

        allow = (
          request.get? or
          (content_type.present? and !BROWSER_GENERATED_TYPES.include?(content_type.downcase)) or
          (format.present? and !BROWSER_GENERATED_FORMATS.include?(format)) or
          (sat.present? and sat == params.authenticity_token)
        )
        
        raise "invalid authenticity token!" unless allow

        @authenticity_token = sat
      end
    end
end