require 'text_utils/spec_helper'

describe "Markdown" do
  include RSpec::TextUtilsHelper

  before do
    @processor = TextUtils::Markdown.new
    @options = {format: :markdown}
  end

  it_should_behave_like 'text processor'

  it "should not touch single underscores inside words" do
    process("foo_bar").should include("foo_bar")
  end

  it "should correctly guess links (from error)" do
    to_xhtml("http://some_domain.com http://some_domain.com").css('a').size == 2
  end

  it "should pass smoke test" do
    text = <<MARKDOWN
# Title

**text**
MARKDOWN

    doc = to_xhtml text
    doc.css('h1').first.content.should == 'Title'
    doc.css("p b, p strong").first.content.should == 'text'
  end

  it "should guess urls" do
    doc = to_xhtml "This is a http://www.some.com/some link"
    doc.content.strip.should == "This is a http://www.some.com/some link"
    doc.css("p a").first.to_fuzzy_hash.should == {href: "http://www.some.com/some"}

    # from error
    doc = to_xhtml "http://www.some.com/some"
    doc.content.strip.should == "http://www.some.com/some"
    doc.css("p a").first.to_fuzzy_hash.should == {href: "http://www.some.com/some"}
  end

  it "should recognize code blocks" do
    text = <<MARKDOWN
``` ruby
puts "Hello World"
```
MARKDOWN

    to_xhtml(text).css('code').first.to_fuzzy_hash.should == {class: 'ruby'}
  end

  it "should recognize definitions" do
    text = <<MARKDOWN
Ruby IoC [Micon][micon]

[micon]: https://github.com/alexeypetrushin/micon
MARKDOWN

    to_xhtml(text).css('a').first.to_fuzzy_hash.should == {href: 'https://github.com/alexeypetrushin/micon'}
  end

  context "should correctly use new lines" do
    it "should correctly insert newline (from error)" do
      html = <<HTML
![img] Open Design.
http://oomps.com

[img]: /some_link
HTML

      to_xhtml(html).css('br').size.should == 1
    end

    it "shouldn't add new lines after image (from error)" do
      html = <<HTML
a ![img] b

[img]: /some_link
HTML

      to_xhtml(html).css('br').size.should == 0
    end

    it "should corectly insert new lines" do
      html = <<HTML
a
![img]
b

[img]: /some_link
HTML

      to_xhtml(html).css('br').size.should == 2
    end

    it "should convert \n to <br/>" do
      to_xhtml("foo\nbar").css('br').size.should == 1
    end

    it "shouldn't create newline after > sign (from error)" do
      html = <<HTML
<div>text</div> text
HTML

      to_xhtml(html).css('br').size.should == 0
    end

    it "shouldn't add empty <p> before first line (from error)" do
      process("<span>text</span>text").should_not =~ /<p>\s*<\/p>/
    end
  end
end