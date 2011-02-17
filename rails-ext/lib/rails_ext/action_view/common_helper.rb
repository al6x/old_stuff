module CommonHelper
  # Initialize JavaScripts variables, needed to rails_ext.js works properly.
  def initialize_js_commons
    javascript_tag %{\
$.authenticity_token = "#{form_authenticity_token}";}
  end
  
  # Prepends content to 'content_for'
  def prepend_to name, content = nil, &block
    ivar = "@content_for_#{name}"
    content = capture(&block) if block_given?
    content ||= ""
    stored_content = instance_variable_get(ivar) || ""
    instance_variable_set(ivar, content + stored_content)
    nil
  end

  # Wraps content for 'content_for'
  def wrap_content_for name, &block
    block.should_not! :be_nil
    
    ivar = "@content_for_#{name}"
    content = capture(instance_variable_get(ivar) || "", &block)
    instance_variable_set(ivar, content || "")
    nil
  end
  
  # Has content for 'content_for'
  def has_content_for? name
    ivar = "@content_for_#{name}"
    !instance_variable_get(ivar).blank?
  end
  
  # Escape JS
  def js *args, &block
    escape_javascript *args, &block
  end
  
#   def js_template content, opt, &block
#     opt[:class] ||= ''
#     opt[:class] += ' hidden'
#     
#     html = content || capture(&block)
# 
#     concat %{\
# <textarea class='#{opt[:class]}'>
# #{html}
# </textarea>}
#   end
#   prepare_arguments_for :js_template, {:type => :object, :range => :except_last_hash}, :hash
  
  # def autohide
  #   # request.format == Mime::JS ? 'hidden' : ''
  #   Thread.current[:autohide] ? 'hidden' : ''
  # end
  # 
  # def render_hidden *args, &block
  #   begin
  #     Thread.current[:autohide] = true
  #     render *args, &block
  #   ensure
  #     Thread.current[:autohide] = false
  #   end
  # end
  
  def tidy_html html
    require 'tidy'
    
  	Tidy.path = '/usr/lib/libtidy.dylib' # depends on platform!
    options = {
      :indent => true,
  		:char_encoding => 'utf8',
  		:wrap => 0,
  		:output_xhtml => true,
  		:show_errors => 6,
  		:show_warnings => true,
  		:tab_size => 2,
  		:vertical_space => true,
  		:new_inline_tags => "script"
    }

  	Tidy.open options do |tidy|
      xml = tidy.clean(html)

  		# puts "  Tidy Messages:"
  	  # puts tidy.errors
  	  # puts tidy.diagnostics
      # puts

      # xml.gsub(">\n</script>", "></script>") # tidy makes it newline
      xml
  	end
  end
end

ActionController::Base.send :helper, CommonHelper