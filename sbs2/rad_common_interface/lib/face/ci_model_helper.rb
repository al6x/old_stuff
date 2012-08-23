module Rad::Face::CiModelHelper
  def attachments name, options = {}    
    render_attribute name, options do |fname, value, o|
      html = form_helper.hidden_field_tag(fname, '') + "\n"
      html += form_helper.attachments_tag fname, value, o
      html
    end
  end
end