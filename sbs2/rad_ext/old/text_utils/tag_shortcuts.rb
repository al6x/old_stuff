class TextUtils::TagShortcuts < TextUtils::Processor
  TAGS = {
    /\[clear\]/ => lambda{|match| "<div class='clear'></div>"},
    /\[space\]/ => lambda{|match| "<div class='space'></div>"}
  }

  def call data, env
    TAGS.each do |k, v|
      data = data.gsub(k, &v)
    end

    call_next markdown, env
  end
end