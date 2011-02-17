# 
# link_to without form creating mess
# and link_to with ajax support
# 
String.send :class_eval do
  attr_accessor :_url_format
end

ActionController::UrlRewriter.send :class_eval do
  def rewrite(options = {})
    url = rewrite_url(options)

    # needed for link_to with ajax
    url._url_format = options[:format] if options[:format]
    url
  end
end

ActionView::Helpers::UrlHelper.send :class_eval do 
  AJAX_FORMATS = ['js', 'json']
  
  def url_for(options = {})
    options ||= {}
    url = case options
    when String
      escape = true
      options
    when Hash
      options = { :only_path => options[:host].nil? }.update(options.symbolize_keys)
      escape  = options.key?(:escape) ? options.delete(:escape) : true
      @controller.send(:url_for, options)
    when :back
      escape = false
      @controller.request.env["HTTP_REFERER"] || 'javascript:history.back()'
    else
      escape = false
      polymorphic_path(options)
    end

    # changes begins here
    if escape
      _url_format = url._url_format
      url = escape_once(url)
      url._url_format = _url_format
    end
    url
  end
    
  def link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      concat(link_to(capture(&block), options, html_options))
    else
      name         = args.first
      options      = args.second || {}
      html_options = args.third
  
      url = url_for(options)
      
      # html_options
      html_options ||= {}
      html_options = html_options.stringify_keys
  
      html_options['ajax'] ||= (url._url_format and AJAX_FORMATS.include? url._url_format.to_s)
  
      href = html_options['href']
      convert_options_to_javascript!(html_options, url)
      tag_options = tag_options(html_options)
  
      href_attr = "href=\"#{url}\"" unless href
      "<a #{href_attr}#{tag_options}>#{name || url}</a>"
    end
  end
  
  private
  def convert_options_to_javascript!(html_options, url = '')
    confirm, ajax = html_options.delete("confirm"), (html_options.delete('ajax') || false)
  
    method, href = html_options.delete("method"), html_options['href']
  
    onclick = if ajax
      method ||= :get
      %{$(this).link_to({method: '#{method}', ajax: true}); return false;}
    elsif method
      %{$(this).link_to({method: '#{method}'}); return false;}
    else
      nil
    end
    
    if onclick and ActionController::Base.defer_static_scripts?
      html_options['class'] ||= ""
    end
    
    if confirm 
      onclick = if onclick
        "if (#{confirm_javascript_function(confirm)}) { #{onclick} };return false;"
      else
        "return #{confirm_javascript_function(confirm)};"
      end
    end
    
    html_options["onclick"] = onclick if onclick
  end
end