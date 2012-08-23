# Usage: ActionView::Template.register_template_handler :rb, RubyTemplate

class RubyTemplate < ActionView::TemplateHandler
  include ActionView::TemplateHandlers::Compilable

  def compile(template)
    # "_set_controller_content_type(Mime::XML);" +
    # "xml = ::Builder::XmlMarkup.new(:indent => 2);" +
    # "self.output_buffer = xml.target!;" +
    "self.output_buffer = '';\n" + template.source
    # ";xml.target!;"
  end
end