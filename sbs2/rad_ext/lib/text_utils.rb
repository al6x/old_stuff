require 'text_utils/_support'

module TextUtils
  autoload :CodeHighlighter, 'text_utils/code_highlighter'
  autoload :CustomMarkdown,  'text_utils/custom_markdown'
  autoload :EnsureUtf,       'text_utils/ensure_utf'
  autoload :FormatQualifier, 'text_utils/format_qualifier'
  autoload :HtmlSanitizer,   'text_utils/html_sanitizer'
  autoload :Markdown,        'text_utils/markdown'
  autoload :Pipe,            'text_utils/pipe'
  autoload :Processor,       'text_utils/processor'
  autoload :Truncate,        'text_utils/truncate'

  class << self
    def markup data
      ps = []
      ps << EnsureUtf
      ps << HtmlSanitizer
      ps << FormatQualifier
      # ps << CodeHighlighter
      ps << CustomMarkdown
      ps << Markdown

      markup = Pipe.new *ps
      markup.call data
    end

    def truncate data, length
      truncate = Pipe.new(
        EnsureUtf,
        HtmlSanitizer,
        FormatQualifier,
        [Truncate, length]
      )
      truncate.call data
    end
  end
end