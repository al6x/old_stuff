class TextUtils::CodeHighlighter < TextUtils::Processor
  # Highlights code inside of <code lang/language='java'> ... code ... </code>.
  def call data, env
    require 'nokogiri'

    snippets = {}

    # Processign html :code tags.
    data = data.gsub /(<code.*?>)(.+?)(<\/code\s*>)/im do
      node = Nokogiri::HTML($1 + $3).css('code').first
      language = node.attributes['lang'].try(:value) || node.attributes['language'].try(:value)
      code = $2

      if language and code
        attributes = {}; node.attributes.each{|name, value| attributes[name] = value.value}
        code = colorize code, language, attributes
        cut_snippet snippets, code
      else
        $&
      end
    end

    # Processign markdown ``` tags.
    data = data.gsub /^```\s*([a-z\-_0-9]+)\s*\n(.+?)^```\s*$/im do
      language, code = $1, $2

      if language and code
        code = colorize code, language, {language: language}
        cut_snippet snippets, code
      else
        $&
      end
    end

    data = call_next data, env

    restore_snippet snippets, data
  end

  protected
    # Temporarilly removing all highlighted code from html to prevent it's beed damaged by next processors.
    def cut_snippet snippets, code
      key = "CODESNIPPET#{snippets.size}"
      snippets[key] = code
      key
    end

    # Inserting cutted code back to html.
    def restore_snippet snippets, data
      data = data.gsub /(CODESNIPPET[0-9]+)/ do |key|
        snippets[key]
      end
      data
    end

    def colorize code, language, attributes
      require 'albino'
      code = Albino.colorize(code, language.to_sym)
      code = "<code #{attributes.to_a.collect{|k, v| "#{k}='#{v}'"}.join(' ')}>\n#{code}\n</code>"
      code = rewrite_styles code
    end

    # Adding prefix 'hl_' to all class names.
    def rewrite_styles html
      node = Nokogiri::HTML(html).css('code').first
      node.css("*").each do |e|
        classes = e.attribute 'class'
        if classes and classes.value
          classes = classes.value.strip.split(/\s+/).collect{|c| "hl_#{c}"}.join(' ')
          e['class'] = classes
        end
      end
      node.to_s
    end
end