class TextUtils::Truncator < TextUtils::Processor
  def initialize processor, length
    super(processor)

    @chain = build_from(
      TextUtils::EnsureUtf,
      [TextUtils::Truncate, length]
    )
  end

  def call text_or_html, env
    text_or_html = @chain.process text_or_html, env
    call_next text_or_html, env
  end
end