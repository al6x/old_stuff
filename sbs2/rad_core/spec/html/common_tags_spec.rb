require 'html/spec_helper'

describe "CommonTags" do
  before do
    @t = TestTemplateContext.new
  end

  it "tag" do
    @t.tag(:div, 'content', class: 'hidden').should == %(<div class="hidden">content</div>)
    @t.tag(:div, class: 'hidden'){'content'}
    @t.buffer.should == %(<div class="hidden">content</div>)
  end

  it "stylesheet_link_tag"  do
    @t.stylesheet_link_tag('/public/js/app.css').should == %(<link href="/public/js/app.css" media="screen" rel="stylesheet" type="text/css"></link>)
  end

  it "javascript_include_tag" do
    @t.javascript_include_tag('/public/js/app.js').should == %(<script src="/public/js/app.js" type="text/javascript"></script>)
  end

  it "image_tag" do
    @t.image_tag('face.png', width: 100).should == %(<img src="face.png" width="100"></img>)
  end

  describe "basic html tags" do
    it "label" do
      @t.label_tag('book', 'Book').should == %(<label for="book">Book</label>)
    end
  end
end