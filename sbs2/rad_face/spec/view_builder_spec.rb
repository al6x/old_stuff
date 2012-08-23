require 'spec_helper'

describe "Template" do
  with_view_path spec_dir
  
  inject template: :template
  
  before do
    @view_builder = Rad::Face::ViewBuilder.new rad.template
    @view_builder.stub!(:themed_partial){|partial| partial}
  end
  
  it "should threat string with newlines as a blank string" do
    @view_builder.render_block('/blank_symbols', content: "\n").should =~ /content blank/
  end
end