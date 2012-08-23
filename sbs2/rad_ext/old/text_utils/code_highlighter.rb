class TextUtils::CodeHighlighter < TextUtils::Processor

  # highlights code inside of <code lang/language='java'> ... code ... </code>
  def call html, env
    require 'coderay'
    require 'nokogiri'

    snippets, unique_id = {}, 0

    # Highlighting
    html = html.gsub /(<code.*?>)(.+?)(<\/code\s*>)/im do
      begin
        node = Nokogiri::HTML($1 + $3).css('code').first
        language = node.attributes['lang'].try(:value) || node.attributes['language'].try(:value)
        code = $2

        if language.present? and code.present?
          attributes = []
          node.attributes.each do |name, value|
            attributes << %(#{name}="#{value.value}")
          end

          code = CodeRay.scan(code, language.downcase.to_sym).div :css => :class

          snippet = "<code #{attributes.join(' ')}>\n#{code}\n</code>"

          # adding prefix 'hl_' to all CodeRay classes
          node = Nokogiri::HTML(snippet).css('code').first
          node.css("*").each do |e|
            classes = e.attribute 'class'
            if classes.present? and classes.value.present?
              classes = classes.value.strip.split(/\s+/).collect{|c| "hl_#{c}"}.join(' ')
              e['class'] = classes
            end
          end
          snippet = node.to_s
        end
      # rescue StandardError => e
      #   rad.logger.warn "CodeHighlighter: #{e.message}"
      end

      # temporarilly removing all highlighted code from html to prevent it's beed damaged by next processors
      unique_id += 1
      id = "CODE#{unique_id}CODE"
      snippets[id] = snippet
      id
    end

    html = call_next html, env

    # inserting highlighted code back to html
    html = html.gsub /(CODE[0-9]+CODE)/ do |id|
      snippets[id]
    end

    html
  end
end