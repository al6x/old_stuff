# Sets format for :js as :html and wraps body into <textarea>
# Forms with files can be submitted by ajax only via iframe, and it requires 
# the response have 'html' encoding and be wrapped into <textarea>
class AjaxHelper < Conveyors::Processor      
  def call
    response = workspace.response.must_be.defined
    request = workspace.request.must_be.defined
    
    next_processor.call
    
    if workspace.params? and workspace.params.format == 'js' and !request.xhr?
      response.content_type = Mime['html']
      workspace.content = "<textarea>#{workspace.content}</textarea>"
    end          
  end
end