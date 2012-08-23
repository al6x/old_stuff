require 'rack'

class Rad::Http::RackRequest < Rack::Request
  # Returns an array of acceptable media types for the response
  # def accept
  #   @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.split(';')[0].strip }
  # end
  #
  # def secure?
  #   (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
  # end

  # Returns all the \subdomains as an array, so <tt>["dev", "www"]</tt> would be
  # returned for "dev.www.rubyonrails.org". You can specify a different <tt>tld_length</tt>,
  # such as 2 to catch <tt>["www"]</tt> instead of <tt>["www", "rubyonrails"]</tt>
  # in "www.rubyonrails.co.uk".
  def subdomains(tld_length = 1)
    return [] unless named_host?(host)
    parts = host.split('.')
    parts[0..-(tld_length+2)]
  end

  # Returns the \domain part of a \host, such as "rubyonrails.org" in "www.rubyonrails.org". You can specify
  # a different <tt>tld_length</tt>, such as 2 to catch rubyonrails.co.uk in "www.rubyonrails.co.uk".
  def domain(tld_length = 1)
    return nil unless named_host?(host)
    host.split('.').last(1 + tld_length).join('.')
  end

  alias_method :cookies_without_memory, :cookies
  def cookies
    @cookies_with_memory ||= cookies_without_memory
  end

  alias_method :method, :request_method

  def normalized_domain
    return nil unless named_host?(host)
    host.sub('www.', '').downcase
  end

  def from_browser?
    content_type.present? and rad.http.browser_generated_types.include?(content_type.downcase)
  end

  class << self
    def stub url = '/'
      env = stub_environment(url)
      Rad::Http::RackRequest.new env
    end

    def stub_environment url = nil
      env = {
        'rack.url_scheme' => 'http',
        'PATH_INFO' => '/',
        'HTTP_HOST' => 'test.com',
        'rack.input' => StringIO.new
      }
      if url
        uri = Uri.parse url
        env.merge!(
          'HTTP_HOST'    => %(#{uri.host}#{":#{uri.port}" if uri.port.present?}),
          # 'REQUEST_PATH' => uri.path,
          'PATH_INFO'    => uri.path,
          # 'REQUEST_URI'  => uri.path,
          'QUERY_STRING' => uri.query
        )
      end
      env
    end
  end

  protected
    def named_host?(host)
      !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
    end
end