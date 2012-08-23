class TextUtils::Markdown < TextUtils::Processor
  DEFAULT_OPTIONS = {
    no_intra_emphasis:   true,
    fenced_code_blocks:  true,
    autolink:            true,
    strikethrough:       true,
    lax_html_blocks:     true,
    space_after_headers: true
  }
  # [:autolink, :lax_htmlblock, :smart, :tables, :xhtml, :fenced_code, :strikethrough, :hard_wrap]

  def initialize processor = nil, options = {}
    super processor

    @options = DEFAULT_OPTIONS.merge options
  end

  def call data, env
    data = markdown.render data if env[:format]
    call_next data, env
  end

  # require 'redcarpet'
  #
  # data = fix_new_lines data do |data|
  #   markdown = Redcarpet.new(data, *@options)
  #   markdown.to_html
  # end

  protected
    attr_reader :options

    def markdown
      require 'redcarpet'

      @markdown ||= begin
        renderer = Redcarpet::Render::XHTML.new hard_wrap: true
        Redcarpet::Markdown.new renderer, options
      end
    end

    # # Remove line breaks after images.
    # def fix_new_lines data, &block
    #   data = block.call data
    #
    #   data.gsub /(<img.+?\/>)\s*(<br\s*\/>)\s*\n/ do
    #     $1
    #   end
    # end
end