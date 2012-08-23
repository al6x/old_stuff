$previous_page_size = 0

# Extractor
BAD_SYMBOLS = {
  "&#151;" => "-",
  "&#133;" => "...",
  "&laquo;" => "\"",
  "&raquo;" => "\"",
  "&nbsp;" => " "
}  

$tec4y.extractor = ETL::Extractor.new $tec4y.base, "www.kinopoisk.ru", 
  # :clear => true, 
  # :pause => 1,
  # :limit => 1,
  
  :header => {
    'Host' => 'www.kinopoisk.ru',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.8) Gecko/20100202 Firefox/3.5.8',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language' => 'en-us,en;q=0.5',
    'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
    'Keep-Alive' => '300',
    'Connection' => 'keep-alive',
    'Cookie' => '	__utma=168025541.436023981.1264126088.1267564176.1267686886.33; __utmz=168025531.1267312452.16.7.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=%D1%82%D0%B5%D1%80%D0%BC%D0%B8%D0%BD%D0%B0%D1%82%D0%BE%D1%80; last_visit=2010-03-04+10%3A15%3A48; users_info[check_sh_bool]=none; search_last_month=2010-02; bblastvisit=1265110928; bblastactivity=0; PHPSESSID=00c195dc9743837185f37a0c81e1e378; __utmb=168025531.76.10.1267686886; __utmc=168025531',
    'Cache-Control' => 'max-age=0'
  },
  
  :skip_urls => [
    # %r{\/bo\/},
    # %r{\/tmp\/},
    # %r{\/level\/7\/},
    # %r{\/query\/},
    # %r{\/index\.php\?level\=7\&\*}
  ],
  :allowed_urls => [
    %r{\/level\/10\/m_act.*genre.*\/2\/m_act.*what.*\/item\/m_act.*all.*\/ok\/},
    
    %r{\/level\/1\/film\/},
    %r{\/level\/13\/film\/},
    %r{\/level\/17\/film\/},
    %r{\/level\/90\/film\/},
    %r{\/picture\/},
    
    %r{\/level\/4\/people\/}
  ],
  :save_urls => {
    %r{\/level\/1\/film\/} => 'movie',
    %r{\/level\/13\/film\/} => 'screenshots',    
    %r{\/level\/17\/film\/} => 'posters',    
    %r{\/level\/90\/film\/} => 'similar_movies',
    %r{\/picture\/} => 'screenshot',
    
    %r{\/level\/4\/people\/} => 'person',
    %r{\/level\/13\/people\/} => 'person_photos'
  },
  :save_resources => false,
  :allowed_resources => [
    %r{\/images\/film\/},
    %r{\/im\/poster\/},
    %r{\/im\/kadr\/},
    
    %r{\/images\/actor\/}
  ],
  :skip_resources => [],
  
  :valid_page => lambda{|page| page.include? '2003'},
  :to_utf => lambda{|html| 
    html = Iconv.conv('UTF-8//IGNORE//TRANSLIT', 'windows-1251', html)
    html = html.gsub /<meta[^>]+?>/, '' 
    BAD_SYMBOLS.each{|from, to| html.gsub! from, to}    
    html
  },  
  # :dont_convert_to_xhtml => true,
  # :stop_if => lambda{|page| prev = $previous_page_size; $previous_page_size = page.size; prev == page.size}, #  'cap_img'
 
  :start_links => ["/level/10/m_act%5Bgenre%5D/2/m_act%5Bwhat%5D/item/m_act%5Ball%5D/ok/"]