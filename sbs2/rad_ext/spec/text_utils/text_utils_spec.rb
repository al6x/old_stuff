require 'text_utils/spec_helper'

describe "TextUtils" do
  it "should truncate" do
    TextUtils.truncate('lorem ipsum', 10).should == 'lorem ...'
  end

  it "should process markdown (should qualify markdown format automatically)" do
    TextUtils.markup('lorem **ipsum**').should == '<p>lorem <strong>ipsum</strong></p>'
  end

  it "should process html (should qualify html format automatically)" do
    TextUtils.markup('<p>lorem **ipsum**</p>').should == '<p>lorem **ipsum**</p>'
  end

#   TODO fixme.
#   it "should highlight code" do
#     markdown = <<MARKDOWN
# code
#
# ``` ruby
# puts "Hello World"
# ```
# MARKDOWN
#
#     TextUtils.markup(markdown).should =~ /span/i
#   end
end