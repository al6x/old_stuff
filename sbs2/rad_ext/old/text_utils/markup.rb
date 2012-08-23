class TextUtils::Markup < TextUtils::Processor

  def initialize processor = nil
    super

    @markup = build_from(
      TextUtils::EnsureUtf,
      TextUtils::HtmlSanitizer,

      TextUtils::CodeHighlighter,

      TextUtils::CustomMarkdown,

      TextUtils::Urls,
      TextUtils::TagShortcuts
    )

    @html = build_from(
      TextUtils::EnsureUtf,
      TextUtils::HtmlSanitizer,
      TextUtils::CodeHighlighter
    )
  end

  def call text, env
    return text if text.blank?

    if text =~ /\A\[html\]/i
      text = text.sub(/\A\[html\][\s\n\r]*/i, '')
      chain = @html
    else
      chain = @markup
    end

    text = chain.process text, env

    unless text.encoding == Encoding::UTF_8
      raise "something wrong happens, invalid encoding (#{text.encoding} instead of utf-8)!"
    end

    call_next text, env
  end
end