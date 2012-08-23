class String
  def json_escape
    ERB::Util.json_escape self
  end

  HTML_ESCAPE_MAP = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
  def html_escape
    # Both ERB and Rack are escape the '/' character, and it's wrong because
    # it destroys links (like '/default/my_item').

    # ERB::Util.html_escape self
    # Rack::Utils.escape_html self

    gsub(/[&"><]/){|special| HTML_ESCAPE_MAP[special]}
  end

  def url_escape
    # TODO2 change to Rack::Utils.escape
    require 'cgi'
    CGI.escape self
  end
  alias_method :uri_escape, :url_escape

  def url_unescape
    # TODO2 change to Rack::Utils.unescape
    require 'cgi'
    CGI.unescape self
  end
  alias_method :uri_unescape, :url_unescape

  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "'"     => "\\'"
  }
  def js_escape
    gsub(/(\\|<\/|\r\n|[\n\r"'])/){JS_ESCAPE_MAP[$1]}
  end

  # String marks, like :format, :safe
  # TODO2 remove it?
  def marks; @marks ||= OpenObject.new end
end