require 'digest/md5'

String.class_eval do
  def to_url_with_escape
    to_url_without_escape.gsub /[^a-z0-9_-]/, ''
  end
  alias_method_chain :to_url, :escape
end

class TextUtils
  RELAXED = {
    :elements => [
      'a', 'b', 'blockquote', 'br', 'caption', 'cite', 'code', 'col',
      'colgroup', 'dd', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 'small', 'strike', 'strong',
      'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'u',
      'ul', 'div', 'font', 'span'],

    :attributes => {
      :all         => ['class', 'style'],
      'a'          => ['href', 'title', 'rel'],
      'blockquote' => ['cite'],
      'col'        => ['span', 'width'],
      'colgroup'   => ['span', 'width'],
      'img'        => ['align', 'alt', 'height', 'src', 'title', 'width'],
      'ol'         => ['start', 'type'],
      'q'          => ['cite'],
      'table'      => ['summary', 'width'],
      'td'         => ['abbr', 'axis', 'colspan', 'rowspan', 'width'],
      'th'         => ['abbr', 'axis', 'colspan', 'rowspan', 'scope', 'width'],
      'ul'         => ['type']
    },

    :protocols => {
      'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
      'blockquote' => {'cite' => ['http', 'https', :relative]},
      'img'        => {'src'  => ['http', 'https', :relative]},
      'q'          => {'cite' => ['http', 'https', :relative]}
    }
  }  
  
  class << self
    
    def markup text
      return text if text.blank?

      text = if text =~ /\A\[html\]/i
        html_mode text
      else
        markdown_mode text
      end
      
    end
    
    def html_mode text
      text = text.sub(/\A\[html\][\s\n\r]*/i, '')
      text = do_sanitaize text
      text = Iconv.conv('UTF-8//IGNORE//TRANSLIT', 'UTF-8', text)
      text
    end
    
    def markdown_mode text
      text = gfm text      
      text = simplified_image_box text            
      text = hide_html_elements text # becouse markdown doesn't apply inside of html elements
      
      text = do_markdown text

      text = restore_html_elements text      
      
      text = StringParser.urls_to_links text
      
      text = do_sanitaize text
      
      text = embed_metaweb text
      text = embed_tags text
      
      text = text.gsub /[\n]+/, "\n"      
      
      # text = text.gsub("”", "\"").gsub("“", "\"") # hack for Maruku special symbols
      
      # Escape all non-word unicode symbols, otherwise it will raise error when converting to BSON
      text = Iconv.conv('UTF-8//IGNORE//TRANSLIT', 'UTF-8', text)
      
      text
    end
    
    def random_string length = 3
      @digits ||= ('a'..'z').to_a + (0..9).to_a
      (0..(length-1)).map{@digits[rand(@digits.size)]}.join
    end
    
    def truncate str_or_html, length
      str_or_html ||= ""
      
      # Sanitize
      str_or_html = do_sanitaize str_or_html
      
      # Strip from HTML tags
      str_or_html = str_or_html.gsub("<br", " <br").gsub("<p", " <p") # to preserve space in place of <> html elements
      doc = Nokogiri::XML("<div class='root'>#{str_or_html}</div>")
      str = doc.css('.root').first.content

      str = str.gsub(/\s+/, ' ')

      
      # Truncate with no broken words
      if str.length >= length
        shortened = str[0, length]
        splitted = shortened.split(/\s/)
        words = splitted.length
        splitted[0, words-1].join(" ") + ' ...'
      else
        str
      end
    end
    
    protected
      def hide_html_elements text
        text.gsub('<', 'HTML_BEGIN').gsub('>', 'HTML_END')
      end
      
      def restore_html_elements text
        text.gsub('HTML_BEGIN', '<').gsub('HTML_END', '>')
      end      
    
      def do_markdown text
        # Maruku.new(text).to_html
        text = text.gsub(" \n", "<br/>\n")
        
        text = BlueCloth.new(text).to_html
        
        text.gsub(/\A<.+?>/){"#{$&} "}.gsub(/<\/.+?>\Z/){" #{$&}"}
      end
      
      # Github Flawered Markdown
      def gfm(text)
        # Extract pre blocks
        extractions = {}
        text.gsub!(%r{<pre>.*?</pre>}m) do |match|
          md5 = Digest::MD5.hexdigest(match)
          extractions[md5] = match
          "{gfm-extraction-#{md5}}"
        end

        # prevent foo_bar_baz from ending up with an italic word in the middle
        text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x|
          x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
        end

        # in very clear cases, let newlines become <br /> tags
        text.gsub!(/^[\w\<\!][^\n]*\n+/) do |x|
          if x =~ /\>[\n\r]*/
            x
          else
            x =~ /\n{2}/ ? x : (x.strip!; x << " \n")
          end
        end

        # Insert pre block extractions
        text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
          "\n\n" + extractions[$1]
        end

        text
      end
    
      def do_wikitext text        
        parser = Wikitext::Parser.new
        parser.autolink = false
        parser.internal_link_prefix = nil
        parser.external_link_class = nil
        parser.mailto_class = nil
        parser.img_prefix = nil
        parser.space_to_underscore = false        
        escaped_html = parser.parse(text)
        html = CGI.unescapeHTML escaped_html
        html
      end
      
      def do_sanitaize html
        Sanitize.clean(html, RELAXED.merge(
          :transformers => [EMBEDDED_VIDEO],
          :add_attributes => {
            :all => [:class]
          }
        ))        
      end
      
      VIDEO_URLS = [
        /^http:\/\/(?:www\.)?youtube\.com\/v\//,
      ]
      
      EMBEDDED_VIDEO = lambda do |env|
        node      = env[:node]
        node_name = node.name.to_s.downcase
        parent    = node.parent
        
        # Since the transformer receives the deepest nodes first, we look for a
        # <param> element or an <embed> element whose parent is an <object>.
        return nil unless (node_name == 'param' || node_name == 'embed') && parent.name.to_s.downcase == 'object'
        
        if node_name == 'param'
          # Quick XPath search to find the <param> node that contains the video URL.
          return nil unless movie_node = parent.search('param[@name="movie"]')[0]
          url = movie_node['value']
        else
          # Since this is an <embed>, the video URL is in the "src" attribute. No
          # extra work needed.
          url = node['src']
        end
        
        # # Verify that the video URL is actually a valid YouTube video URL.
        return nil unless VIDEO_URLS.any?{|t| url =~ t}
        
        # # We're now certain that this is a YouTube embed, but we still need to run
        # # it through a special Sanitize step to ensure that no unwanted elements or
        # # attributes that don't belong in a YouTube embed can sneak in.
        Sanitize.clean_node!(parent, {
          :elements   => ['embed', 'object', 'param'],
          :attributes => {
            'embed'  => ['allowfullscreen', 'allowscriptaccess', 'height', 'src', 'type', 'width'],
            'object' => ['height', 'width'],
            'param'  => ['name', 'value']
          }
        })

        # Now that we're sure that this is a valid YouTube embed and that there are
        # no unwanted elements or attributes hidden inside it, we can tell Sanitize
        # to whitelist the current node (<param> or <embed>) and its parent
        # (<object>).
        {:whitelist_nodes => [node, parent]}
      end
    
      # !![img] => [![img_thumb]][img]
      def simplified_image_box text
        img_urls = {}
        text = text.gsub(/!!\[(.+?)\]/) do
          img_key = $1
          if url = text.scan(/\[#{img_key}\]:\s*([^\s]+)$/).first.try(:first)
            unless url =~ /\.[^\.]+\.[^\.]+$/ # image.png
              thumb_img_key = "#{img_key}_thumb"
            
              # building url with thumb (foo.png => foo.thumb.png)
              img_urls[thumb_img_key] = url.sub(/\.([^\.]+)$/){".thumb.#{$1}"}
            
              "[![][#{thumb_img_key}]][#{img_key}]"
            else # image.(icon|thumb|...).png
              img_key_full = "#{img_key}_full"
            
              # building url with thumb (foo.png => foo.thumb.png)
              img_urls[img_key_full] = url.sub(/\.([^\.]+)\.([^\.]+)$/){".#{$2}"}
            
              "[![][#{img_key}]][#{img_key_full}]"
            end
          else  
            $&
          end
        end
        
        unless img_urls.blank?
          text << "\n"
          text << img_urls.to_a.collect{|k, v| "[#{k}]: #{v}"}.join("\n")
        end
        text
      end
      
      # {metaweb:google_web_toolkit} => wiget html
      def embed_metaweb text
        html = <<HTML
<div itemtype="http://www.freebase.com/id/computer/software" itemid="http://www.freebase.com/id/en/google_web_toolkit" itemscope="" style="border: 0pt none; outline: 0pt none; padding: 0pt; margin: 0pt; position: relative;" id="fbtb-6ffc2545598340cbbc7945f43ebd45de" class="fb-widget">
    <iframe frameborder="0" scrolling="no" src="http://www.freebase.com/widget/topic?track=topicblocks_homepage&amp;mode=content&amp;id=%2Fen%2F_topic_name_" style="height: 285px; width: 413px; border: 0pt none; outline: 0pt none; padding: 0pt; margin: 0pt;" classname="fb-widget-iframe" allowtransparency="true" class=" "></iframe>
    <script defer="" type="text/javascript" src="http://freebaselibs.com/static/widgets/2/widget.js"></script>
</div>
HTML
        text.gsub(/\{metaweb:(.+?)\}/){html.gsub('_topic_name_', $1)}
      end
      
      TAGS = {
        /\[clear\]/ => lambda{"<div class='clear'></div>"},
        /\[space\]/ => lambda{"<div class='space'></div>"}
      }
      
      def embed_tags text
        TAGS.each do |k, v|
          text.gsub!(k, &v)
        end
        text
      end
      
      
    # def slug text
    #   return "" if text.blank?
    #   text.gsub(/[^A-Za-z0-9\s\-]/, "")[0,20].strip.gsub(/\s+/, "-").downcase
    # end
  end
  
  
  # Code ripped from StringParser, http://github.com/snitko/string_parser/blob/master/lib/string_parser.rb
  module StringParser
    class << self
      
      # Creates <a> tags for all urls.
      # IMPORTANT: make sure you've used #urls_to_images method first
      # if you wanted all images urls to become <img> tags.
      def urls_to_links html
        # becouse it finds only one url in such string "http://some_domain.com http://some_domain.com" we need to aply it twice
        regexp, sub = /(\s|^|\A|\n|\t|\r)(http:\/\/.*?)([,.])?(\s|$|\n|\Z|\t|\r|<)/, '\1<a href="\2">\2</a>\3\4'
        html = html.gsub regexp, sub
        html.gsub regexp, sub
        html
      end
      
      # Highlights code using 'uv' library.
      # Make sure you have ultraviolet gem installed.
      def highlight_code(options={})
        require 'uv'

        wrap_with = options[:wrap_with] || ['','']
        text = @modified_string

        languages_syntax_list = File.readlines(
          File.expand_path(File.dirname(__FILE__) + '/../config/languages_syntax_list')
        ).map { |l| l.chomp }

        text.gsub!(/<code(\s*?lang=["']?(.*?)["']?)?>(.*?)<\/code>/) do
          if languages_syntax_list.include?($2)
            lang = $2
          else
            lang = 'ruby'
          end
          unless $3.blank?
            result = Uv.parse($3.gsub('<br/>', "\n").gsub('&lt;', '<').gsub('&gt;', '>').gsub('&quot;', '"'), 'xhtml', lang, false, 'active4d')
            "#{wrap_with[0].gsub('$lang', lang)}#{result}#{wrap_with[1]}"
          end
        end

        # TODO: split string longer than 80 characters

        @modified_string = text
        self

      end
    end
  end
end