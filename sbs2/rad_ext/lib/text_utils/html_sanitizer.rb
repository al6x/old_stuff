class TextUtils::HtmlSanitizer < TextUtils::Processor
  RULES = {
    elements: [
      'a', 'b', 'blockquote', 'br', 'caption', 'cite', 'code', 'col',
      'colgroup', 'dd', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 'small', 'strike', 'strong',
      'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'u',
      'ul', 'div', 'font', 'span', 'iframe'],

    attributes: {
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
      'ul'         => ['type'],
      'code'       => ['lang', 'language'],

      'iframe'     => ['height', 'width', 'src', 'scrolling', 'frameborder', 'allowfullscreen']
    },

    protocols: {
      'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
      'blockquote' => {'cite' => ['http', 'https', :relative]},
      'img'        => {'src'  => ['http', 'https', :relative]},
      'q'          => {'cite' => ['http', 'https', :relative]}
    }
  }

  def call data, env
    data = call_next data, env

    require 'sanitize'
    Sanitize.clean data, RULES
  end
end