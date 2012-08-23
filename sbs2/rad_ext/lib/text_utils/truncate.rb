class TextUtils::Truncate < TextUtils::Processor
  def initialize processor, length
    super processor
    @length = length
  end

  def call data, env
    data ||= ""

    # Strip from HTML tags
    data = data.gsub("<br", " <br").gsub("<p", " <p")

    require 'nokogiri'
    doc = Nokogiri::XML("<div class='root'>#{data}</div>")
    data = doc.css('.root').first.content

    # remove clear space
    data = data.gsub(/\s+/, ' ')

    # truncate with no broken words
    data = if data.length >= @length
      shortened = data[0, @length]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else
      data
    end

    call_next data, env
  end
end