# Sets format for :js as :html and wraps body into <textarea>
# Forms with files can be submitted by ajax only via iframe, and it requires
# the response have 'html' encoding and be wrapped into <textarea>
class Rad::Web::Processors::AjaxHelper < Rad::Conveyors::Processor
  def call
    response = workspace.response.must.be_defined
    request = workspace.request.must.be_defined

    next_processor.call

    if workspace.params? and workspace.params.format == 'js' and !request.xhr?
      response.content_type = Rad::Mime['html']
      workspace.content = "<textarea>#{workspace.content}</textarea>"
    end
  end
end