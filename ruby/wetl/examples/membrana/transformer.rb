class MembranaToTec4yTransformer < ETL::Transformer
  IMAGE_URL_TEMPLATE = "/system/tech4y/files/:slug/thumb_:fname"
  IMAGE_ORIGINAL_URL_TEMPLATE = "/system/tech4y/files/:slug/original_:fname"
  
  def identity url
    url = extractor.normalize_url url
    
    replace = {
      %r{\/articles\/[^\/]+\/} => "/",
    }
    replace.each{|from, to| url.gsub! from, to}
    url.strip
  end
  
  def extract_tags page
    url = page.url
    if url =~ %r{\/articles\/.+?\/.+?\/.+?\/.+?\/}
      if url =~ /technic/
        ["Технологии"]
      elsif url =~ /imagination/
        ["Необычное"]
      elsif url =~ /global/
        ["Планета"]
      elsif url =~ /business/
        ["Бизнес"]
      elsif url =~ /internet/
        ["Интернет"]
      elsif url =~ /inventions/
        ["Изобретения"]
      elsif url =~ /health/
        ["Медицина"]
      elsif url =~ /simply/
        ["Необычное"]
      elsif url =~ /telecom/
        ["Телеком"]
      elsif url =~ /readers/
        ["Интервью"]
      elsif url =~ /interview/
        ["Интервью"]
      elsif url =~ /tf/
        ["Гаджеты"]
      # elsif url =~ /misinterpretation/
      #   ["Испорченный телефон"]
      else
        []
      end
    else
      ["Новости"]
    end
  end

  def normalize_date date
    # Check Date
    months = {'января' => 1, 'февраля' => 2, 'марта' => 3, 'апреля' => 4, 'мая' => 5, 'июня' => 6, 'июля' => 7,
      'августа' => 8, 'сентября' => 9, 'октября' => 10, 'ноября' => 11, 'декабря' => 12}
    raise "Invalid Date!" unless months.keys.any?{|m| date.include? m}
    date = date.gsub(/\s/, '.')
    months.each{|m, n| date = date.gsub(m, n.to_s)}  
    Time.parse date
  end
  
  def normalize_image_name url
    return "" if url.blank?
    Addressable::URI.parse(url).basename || ""
  end
  
  def image_slug base, image_name
    base ||= ""
    image_name ||= ""
    (base + image_name.gsub(/\..*/, '')).to_url
  end
  
  # Extracting Tags, Title, Icon, Details, Date, Slug, ImageBase
  def parsing_article page, doc
    obj = OpenObject.new
    
    obj.tags = extract_tags page

    if doc.css("table[width='478']").first
      article = doc.css("table[width='478']").first

      obj.title = article.css("font[size='+2']").first.content.strip rescue raise("Blank Title")
      obj.icon = article.css("table > td > img").first[:src] rescue raise("Blank Icon")
      obj.details = article.css("table .az10").first.content.strip rescue raise("Blank Details")

      obj.date = article.css(".az10").first.content.strip rescue raise("Blank Date")
    else
      article = doc.css("td[width='478']").first

      obj.title = article.css("font[size='+2']").first.content.strip rescue raise("Blank Title")    
      obj.icon = article.css("table > td > img").first[:src] rescue raise("Blank Icon")
      obj.details = article.css("p b").first.content.strip rescue raise("Blank Details")

      obj.date = article.css(".z10").first.content.strip rescue raise("Blank Date")    
    end

    obj.icon = normalize_image_name obj.icon
    obj.date = normalize_date obj.date 

    obj.slug = obj.title.to_url.gsub(/[^a-z0-9_-]/, '')[0..100]

    obj.image_base = obj.slug[0..5] + '-'

    # Extracting Text, Links and Images
    abody = article.css("#newsText").first

    # First Paragraph with Icon and Details
    paragraphs = [{:name => obj.icon, :description => obj.details, :type => :image, :slug => image_slug(obj.image_base, obj.icon)}.to_openobject]

    selected_images = [] # select all needed images
    abody.css("table").each do |table|    
      first_non_stub_image = table.css('img').find{|img| img[:src] !~ /1\.gif/}
      selected_images << first_non_stub_image if first_non_stub_image      
    end

    # Add text without <p>
    content = abody.inner_html_in_utf.to_s.gsub("\n", "").gsub(/<.*/, '').strip
    paragraphs << {:text => content, :type => :text}.to_openobject unless content.blank?

    # Text with paragraphs (so complex becouse there can be hierarchy of paragraphs)
    abody.css("*").each do |e|
      name = e.name.to_s.downcase
      if name == 'p' 
        next if e.css('p').size > 0
        content = e.inner_html_in_utf.to_s.strip      
        paragraphs << {:text => content, :type => :text}.to_openobject unless content.blank?
      elsif name == 'img'
        if selected_images.include?(e) and !(src = e[:src]).blank?        
          name = normalize_image_name src
          table = e.ancestors.find{|a| a.name.to_s.downcase == 'table'}
          if table.css('.az10').first
            desc = (table.css('.az10').first.inner_html_in_utf.to_s || "").strip            
            paragraphs << {:name => name, :description => desc, :type => :image, :slug => image_slug(obj.image_base, name)}.to_openobject
          end
        end
      end
    end

    # Collecting Images
    obj.images = []
    (paragraphs.select{|h| h.type == :image}).each do |h|
      # next unless transformer.valid_host? h.name
      next if h.name.blank?
      obj.images << h.name
    end

    obj.text = ""
    paragraphs.each_with_index do |h, index|
      h.type.should! :be_in, [:text, :image]
      
      if h.type == :text
        pr = h.text
      else
        url = IMAGE_URL_TEMPLATE.sub(":slug", h.slug).sub(":fname", obj.image_base + h.name)     
        original_url = IMAGE_ORIGINAL_URL_TEMPLATE.sub(":slug", h.slug).sub(":fname", obj.image_base + h.name)     
        
        pr = %{\
#{"<h2/>" unless index == 0}
<a rel="article_images" class="_image_box" href="#{original_url}">
<img src="#{url}"/>
</a>
<p><b>#{h.description}</b></p>}
      end

      pr += "\n\n" if index < (paragraphs.size - 1)
      obj.text += pr
    end

    raise "Blank Text" if obj.text.blank?    
    raise "Invalid Images" if obj.images.any?{|l| l =~ /1\.gif/ or l =~ /^http/}
    
    obj
  end
  
  def page_to_object_converter page
    # Preparing
    # page.content = Iconv.conv('UTF-8', 'windows-1251', page.content.to_s)
    doc = Nokogiri::XML(extractor.read_page(page.url))    

    obj = parsing_article page, doc

    obj.identity = identity(page.url).should_not_be! :blank
    if objects.find(:identity => obj.identity).count > 0
      []
    else
      # File.open('o.txt', 'w'){|f| f.write obj.to_a.collect{|k, v| "#{k}: #{v}"}.join("\n\n")}
      
      [obj]
    end
  end
  
  def update_links_and_copyrights obj
    doc = Nokogiri::XML("<div class='root'>#{obj.text}</div>")

    doc.css('a').each do |a|
      url = a[:href]    
      url_obj = Addressable::URI.parse url      
      url_path = url_obj.request_uri
      
      # skip image links
      next if a['class'] == "_image_box"
      
      # skip blank urls
      if url_path.blank?
        a['rel'] = 'nofollow'
        next
      end
      
       # skip urls with another hosts            
      unless url_obj.host.blank?
        if Addressable::URI.normalize_host(url_obj.host) != Addressable::URI.normalize_host(extractor.host)
          a['rel'] = 'nofollow'
          next
        end
      end

      # rewrite urls to other articles
      identity = identity(url_path)
      if ref_obj = objects.find_one(:identity => identity)
        new_url = "/pages/#{ref_obj['slug']}"        
        a['href'] = new_url
      else
        a['rel'] = 'nofollow'
        p "Can't rewrite URL #{url}" 
      end          
    end

    obj.text = doc.css('.root').first.inner_html_in_utf

    obj.text += %{\n\n<a href="http://www.membrana.ru/" rel="nofollow" class="cr">По материалам интернет-журнала MEMBRANA</a>}
    
    [obj]
  end
  
  def correct_html obj
    html = "<div class='root'>#{obj.text}</div>"
    doc = Nokogiri::HTML(html)
    xhtml = doc.to_xhtml :encoding => 'UTF-8'

    doc = Nokogiri::XML(xhtml)  
    obj.text = doc.css('.root').first.inner_html_in_utf
    
    [obj]
  end
end

$tec4y.transformer = MembranaToTec4yTransformer.new $tec4y.base, $tec4y.extractor do |t|
  t.convert_pages_to_objects :page_to_object_converter
  t.update_objects_to 1, :update_links_and_copyrights
  t.update_objects_to 2, :correct_html  
end