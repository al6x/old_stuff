class TextUtils::Urls < TextUtils::Processor
  # Creates <a> tags for all urls.
  # IMPORTANT: make sure you've used #urls_to_images method first
  # if you wanted all images urls to become <img> tags.
  def call html, env
    # becouse it finds only one url in such string "http://some_domain.com http://some_domain.com" we need to aply it twice
    regexp, sub = /(\s|^|\A|\n|\t|\r)(http:\/\/.*?)([,.])?(\s|$|\n|\Z|\t|\r|<)/, '\1<a href="\2">\2</a>\3\4'
    html = html.gsub regexp, sub
    html.gsub regexp, sub

    call_next html, env
  end
end