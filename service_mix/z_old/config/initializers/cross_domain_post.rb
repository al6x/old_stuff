# # Needed to Cross Domain Post
# module ActionController
#   class Request
#     def request_method
#       # @request_method ||= begin
#       #   method = (parameters[:_method].blank? ? @env['REQUEST_METHOD'] : parameters[:_method].to_s).downcase
#       #   if ACCEPTED_HTTP_METHODS.include?(method)
#       #     method.to_sym
#       #   else
#       #     raise UnknownHttpMethod, "#{method}, accepted HTTP methods are #{ACCEPTED_HTTP_METHODS.to_a.to_sentence}"
#       #   end
#       # end
#       method = @env['REQUEST_METHOD']
#       method = parameters[:_method] unless parameters[:_method].blank?
#       HTTP_METHOD_LOOKUP[method] || raise(UnknownHttpMethod, "#{method}, accepted HTTP methods are #{HTTP_METHODS.to_sentence}")
#     end
#   end
# end