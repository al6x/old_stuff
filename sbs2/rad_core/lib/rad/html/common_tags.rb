module Rad::Html::CommonTags
  BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                       autoplay controls loop selected hidden scoped async
                       defer reversed ismap seemless muted required
                       autofocus novalidate formnovalidate open).to_set
  BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attr| attr.to_sym })

  # StyleSheet.
  def stylesheet_link_tag *stylesheets
    stylesheets.collect{|ssheet|
      tag :link, '', href: "#{ssheet}", media: "screen", rel: "stylesheet", type: "text/css"
    }.join("\n")
  end

  # JavaScript.
  def javascript_include_tag *scripts
    scripts.collect{|script|
      tag :script, '', src: "#{script}", type: "text/javascript"
    }.join("\n")
  end

  def javascript_tag script = nil, options = {}, &block
    script = capture &block if block
    html = tag :script, script, {type: "text/javascript"}
    block ? concat(html) : html
  end

  # Common HTML tags.
  def label_tag name, text, options = {}
    tag :label, text, options.merge(for: name)
  end

  def image_tag src, opt = {}
    opt[:src] = src
    tag :img, '', opt
  end

  # Html tag builder.
  def tag name, content_or_options_with_block = nil, options = nil, escape = true, &block
    if block_given?
      options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
      content = capture(&block)
      concat "<#{name}#{tag_options(options)}>#{content}</#{name}>"
    else
      content = content_or_options_with_block
      "<#{name}#{tag_options(options)}>#{content}</#{name}>"
    end
  end

  # Escaping HTML and JavaScript
  def h obj; obj.to_s.html_escape end

  def j obj; obj.to_s.json_escape end

  def js obj; obj.to_s.js_escape end

  protected

    def tag_options options
      return "" unless options
      options.must.be_a Hash
      unless options.blank?
        attrs = []
        options.each_pair do |key, value|
          next if key == :content # used in common_interface don't delete it
          if BOOLEAN_ATTRIBUTES.include?(key)
            attrs << %(#{key}="#{key}") if value
          elsif !value.nil?
            final_value = value.is_a?(Array) ? value.join(" ") : value
            attrs << %(#{key}="#{final_value}")
          end
        end
        " #{attrs.sort * ' '}" unless attrs.empty?
      end
    end
end