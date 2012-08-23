require 'rspec_ext'
require 'ruby_ext'

require 'text_utils'

require 'text_utils/text_processor_shared'

module RSpec::TextUtilsHelper
  def process data
    @processor.call data, @options
  end

  def to_xhtml data
    process(data).to_xhtml
  end
end

# class String
#   def to_xhtml
#     Nokogiri::HTML(self)
#   end
# end
