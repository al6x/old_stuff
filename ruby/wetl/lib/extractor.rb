class ETL::Extractor
  attr_accessor :base, :host, :options, :directory,
    :links, :pages
  
  def initialize base, host, opt = {}
    self.base = base.should_not! :be_nil
    self.host = host.should_not!(:be_nil).should!(:=~, /[a-z0-9\-_.]+/) #.should_not!(:=~, /^www\./)
    self.options = opt.to_openobject
    self.directory = "#{base.base_directory}/#{host.strong_escape}"
    
    prepare
  end  

  def selected_links_in_page doc            
    urls = []
    doc.css('a').each do |a|
      url = a[:href]
      url_obj = Addressable::URI.parse url      
      
      # Check
      next if url.blank?
      
      # Filtering
      next if options.skip_urls? and options.skip_urls.any?{|t| url =~ t}
      next if options.allowed_urls? and !options.allowed_urls.any?{|t| url =~ t}
      
      unless url_obj.host.blank?
        normalized_url_host = Addressable::URI.normalize_host(url_obj.host)
        normalized_host = Addressable::URI.normalize_host(self.host)
        next if normalized_url_host != normalized_host                
      end
      
      # Normalization
      url = url_obj.normalize.request_uri
      url = normalize_url url
      
      urls << url
    end
    return urls.uniq.sort
  end
  
  def normalize_url url
    if options.normalize_url?
      options.normalize_url.call url
    else
      url
    end
  end

  def each_selected_page &block    
    while links.find(:processed => false).count() > 0
      break if options.limit? and pages.count >= options.limit
      
      current_link = links.find_one :processed => false
      current_url = current_link['url']

      begin
        html = get_page current_url
        xhtml = if options.dont_convert_to_xhtml?
          html
        else
          correct_html_and_convert_to_unicode html
        end
        
        doc = Nokogiri::HTML xhtml
        
        selected_links = selected_links_in_page doc        
        
        if options.stop_if? and options.stop_if.call xhtml
          print_info
          p "Stoping, need manual operation!"
          break
        end
        
        selected_links.each do |url|
          unless links.find_one(:url => url)      
            links.save :url => url, :processed => false unless links.find_one :url => url
          end
        end

        block.call current_url, xhtml, doc
      rescue Exception => e
        p "Bad link: #{e.message} (#{current_url})"
        current_link['error'] = Kconv.toutf8 e.message
      end      

      current_link['processed'] = true
      links.save current_link
      
      sleep options.pause if options.pause?
    end    
  end
  
  def check_and_save_selected url, xhtml, doc
    return unless options.save_urls?
    
    options.save_urls.each do |t, type|
      if url =~ t and !pages.find_one(:url => url, :type => type)        
        prepare_directory_for_page url
                
        save_page url, xhtml, 'original_page'        
        save_resources_for url, xhtml, doc if options.save_resources?
        
        rewriten_xhtml = rewrite_resource_links doc
        save_page url, rewriten_xhtml
        
        pages.save :url => url, :type => type        
        p "Page saved: #{url} (content size #{rewriten_xhtml.size})"        
      end    
    end
  end
  
  def save_resources_for page_url, xhtml, doc
    processed = Set.new
    
    doc.css('img').each do |img|      
      url = img[:src]
      url_obj = Addressable::URI.parse url
      
      # Check
      next if url.blank?
      next if processed.include? url
      processed << url      
            
      img_name = url_obj.basename
      next if img_name.blank?
      
      # Building absolute url
      if url_obj.host.blank?        
        if url =~ /^\//
          url = "http://#{host}#{url}"
        else
          url = "http://#{host}#{page_url}/#{url_path}"
        end
      end
      
      # Filtering
      next if options.skip_resources? and options.skip_resources.any?{|t| url =~ t}
      next if options.allowed_resources? and !options.allowed_resources.any?{|t| url =~ t}
      
      # Getting
      begin        
        p "Getting Image #{url}"
        header = options.header || {}        
        r = RestClient.get url, header
        raise "Emtpy Image" if r.body.blank?
        
        save_image page_url, img_name, r.body
      rescue Exception => e
        p "Bad Image Link: #{url}", e.message
      end
    end
  end
  
  def run
    if options.clear?
      clear
      prepare
    end
    
    # Initial Data
    start_links = options.start_links || ['/']
    start_links.each do |url|
      links.remove :url => url
      links.save :url => url, :processed => false
    end
    
    # Run
    print_info
    each_selected_page do |link, content, doc|
      check_and_save_selected link, content, doc
      print_info
    end    
  end
  
  def print_info
    p "Pages: #{pages.count}, Processed links: #{links.find(:processed => true).count}, To process: #{links.find(:processed => false).count}, Bad links #{links.find(:error => {:$exists => true}).count}"
  end
  
  def reset_bad_links
    links.find(:error => {:$exists => true}).each do |h|
      h.delete 'error'
      h['processed'] = false
      links.save h
    end
  end
  
  def save_image url, name, data    
    p_dir = page_directory url
    raise "Page directory not exist (#{p_dir})!" unless File.exist? p_dir
    
    fname = "#{p_dir}/#{name}"
    File.delete fname if File.exist? fname    
    
    File.open(fname, "wb"){|f| f.write data}
  end
  
  def read_image url, name, &block
    fname = image_file_name url, name
    raise "Page directory not exist (#{fname})!" unless File.exist? fname
    
    if block
      File.open(fname, "rb"){|f| block.call f}
    else
      File.open(fname, "rb"){|f| f.read}
    end
  end
  
  def image_file_name url, name
    "#{page_directory url}/#{name}"
  end
  
  def read_page url, version = 'page'
    fname = "#{page_directory url}/#{version}.html"
    raise "Page not exist (#{fname})!" unless File.exist? fname
    
    File.open(fname, "rb"){|f| f.read}
  end
  
  def save_page url, xhtml, version = 'page'
    p_dir = page_directory url
    raise "Page directory not exist (#{p_dir})!" unless File.exist? p_dir
    
    File.open("#{p_dir}/#{version}.html", "wb"){|f| f.write xhtml}
  end
  
  def page_directory url
    "#{directory}/#{url.strong_escape}"
  end
  
  def clear
    base.db.drop_collection 'links'
    base.db.drop_collection 'pages'
    
    FileUtils.rm_rf directory
  end
    
  protected    
    def prepare
      # DB
      self.pages = base.db.collection 'pages'
      pages.create_index 'url', true

      self.links = base.db.collection 'links'
      links.create_index 'url', true
      links.create_index 'processed', false

      # Directory      
      FileUtils.mkdir_p directory unless File.exist? directory
    end
  
    def prepare_directory_for_page url
      p_directory = page_directory url
      FileUtils.rm_rf p_directory if File.exist? p_directory
      Dir.mkdir p_directory
    end
  
    def rewrite_resource_links doc
      doc.css('img').each do |img|
        url = img[:src]        
        next if url.blank?
        
        url_obj = Addressable::URI.parse url
        img_name = url_obj.basename
        next if img_name.blank?
        
        img['src'] = img_name
      end
      
      doc.to_xhtml :encoding => 'UTF-8'
    end
  
    def get_page url_path
      url_path.should! :=~, /^\//      
      url = "http://#{host}#{url_path}"
      
      p "Getting: #{url}"
      
      header = options.header || {}
      responce = RestClient.get url, header
      html = responce.body
      
      raise 'Empty Body' if html.blank?
      raise 'Invalid Page' if options.valid_page and !options.valid_page.call(html)
      
      html
    end
    
    def correct_html_and_convert_to_unicode html
      html = options.to_utf.call html if options.to_utf?
      
      doc = Nokogiri::HTML(html)      
      xhtml = doc.to_xhtml :encoding => 'UTF-8'
      xhtml
    end
end