# Extractor
REWRITE_URL = [  
  # /\?.*/ => '',
  # "?wire=section" => "",
  # "?wire=readalso" => "",
  # "?wire=mainsection" => "",
  # %r{\/articles\/[^\/]+\/} => "/",
  [/wire=[^&]*/, ''],
  
  ["/lenta/index.html", "/lenta/"],
  ["/lenta/index", "/lenta/"],
  
  [".html", ''],
  ["%20", ''],
  [" ", ''],
  
  [/\?$/, ''],
]
$tec4y.normalize_url = lambda do |url|  
  REWRITE_URL.each{|from, to| url.gsub! from, to}
  url.strip
end


BAD_SYMBOLS = {
  "&#151;" => "-",
  "&nbsp;" => " "
}

$tec4y.extractor = ETL::Extractor.new $tec4y.base, "www.membrana.ru", 
  # :clear => true, 
  # :pause => 1,
  # :limit => 1,
  
  :skip_urls => [
    %r{\/forum\/article}
  ],
  :allowed_urls => [
    %r{\/articles},
    %r{\/lenta\/\?}
  ],
  :save_urls => {
    %r{\/articles\/.+?\/.+?\/.+?\/.+?\/} => 'article',
    %r{\/lenta\/\?\d} => 'article'
  },
  :save_resources => true,
  :allowed_resources => [
    %r{\/images\/forms\/},
    %r{\/images\/articles\/}
  ],
  :skip_resources => [
    %r{\/images\/forms\/thumb\/},
    %r{\/images\/forms\/thumbnails\/},
    %r{\/images\/articles\/thumb\/},
    %r{\/images\/articles\/thumbnails\/}
  ],
  :valid_page => lambda{|xhtml| xhtml.include? 'MEMBRANA'},
  
  :to_utf => lambda{|html| 
    html = Iconv.conv('UTF-8//IGNORE//TRANSLIT', 'windows-1251', html)
    BAD_SYMBOLS.each{|from, to| html.gsub! from, to}
    html
  },
  
  :normalize_url => $tec4y.normalize_url,
  
  # :stop_if => lambda{|page| prev = $previous_page_size; $previous_page_size = page.size; prev == page.size}, #  'cap_img'
  
  :start_links => ["/lenta/", "/articles/"] # ["/articles/imagination/2010/02/09/192800"]