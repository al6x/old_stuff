require 'rack'

class Rad::Http::Response < Rack::Response
  include RubyExt::OpenConstructor

  STATUS_MESSAGES = {
    ok: 200,
    not_found: 404,
    failed: 500,
    error: 500,
    redirect: 302
  }

  def initialize request = nil
    super()
    clear

    if request
      self.format = request.format
    end
  end

  def content_type= type; self["Content-Type"] = type end
  def content_type; self["Content-Type"] end
  def content_type?; !!content_type end

  def location; self['Location'] end
  def location= location; self['Location'] = location end

  def format= format
    self.content_type = Rad::Mime[format]
  end

  def format
    Rad::Mime.format_for self.content_type
  end

  def body_as_string
    if @body.is_a? String
      @body
    else
      @body ? @body.join : ""
    end
  end

  def inspect
    to_a2.inspect
  end

  def == other
    to_a2 == other
  end

  def cookies
    self['Set-Cookie']
  end

  def clear
    @status = 200
    @header = Rack::Utils::HeaderHash.new("Content-Type" => nil)
    @length = 0
    @body = []
  end

  def status= code_or_message
    @status = if code_or_message.is_a? Numeric
      code_or_message
    else
      self.class.decode_status_message(code_or_message) || raise("unknown http status message '#{code_or_message}'!")
    end
  end

  def self.decode_status_message message
    STATUS_MESSAGES[message]
  end

  # In Rack if You write `response.body = 'some string'` it will not
  # work, You should write `response.body = ['some string']`.
  # Fixing it and making it autowrap arguments.
  def body= obj
    super obj.respond_to?(:each) ? obj : [obj]
  end

  # Status helpers.

  STATUS_MESSAGES.each do |message, status_code|
    define_method("#{message}?"){self.status == status_code}
  end
  alias_method :success?, :ok?

  def redirect?
    super or (body and body.include?('window.location'))
  end

  protected
    def to_a2
      [status, header, body_as_string]
    end
end