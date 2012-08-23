String.class_eval do
  unless method_defined? :dirname
    def dirname
      File.expand_path(File.dirname(self))
    end
  end

  # Convert string to HTML node.
  def to_xhtml css = nil
    require 'rspec_ext/nokogiri'

    node = Nokogiri::HTML(self)
    unless css
      node
    else
      nodes = node.css(css)
      raise "Elements for '#{css}' CSS query not found!" if nodes.size < 1
      raise "Found more than one elment for '#{css}' CSS query!" if nodes.size > 1
      nodes.first
    end
  end
end
