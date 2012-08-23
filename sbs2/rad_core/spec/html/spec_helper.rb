require 'spec_helper'

class TestTemplateContext < Rad::Html::TemplateContext
  attr_accessor :capture, :buffer

  def capture &block
    block.call
  end

  def concat value = nil
    @buffer ||= ""
    @buffer << value
    nil
  end
end