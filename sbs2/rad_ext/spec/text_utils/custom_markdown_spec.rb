require 'text_utils/spec_helper'

describe "Markdown" do
  include RSpec::TextUtilsHelper

  before do
    markdown = TextUtils::Markdown.new
    @processor = TextUtils::CustomMarkdown.new markdown
    @options = {format: :markdown}
  end

  it_should_behave_like 'text processor'

  it "should apply markup inside of html elements (from error)" do
    html = <<HTML
<div class='right'>
![img]
</div>

[img]: /some_link
HTML

    to_xhtml(html).css('.right img').size.should == 1
  end

  it "should leave existing links intact" do
    doc = to_xhtml(%{<a href="http://some_domain.com">http://some_domain.com</a>})
    doc.css('a').size.should == 1
    doc.css('a').first['href'].should == "http://some_domain.com"
  end

  describe 'image box' do
    it "should use simplifyed syntax for image boxes (!![img_thumb] => [![img_thumb]][img_full_version])" do
      html = <<HTML
!![img]
![img]

!![img_2]
![img_2]

[img]: /some_prefix/image_name.png
[img_2]: /some_prefix/image_name2.icon.png
HTML

      doc = to_xhtml html
      doc.css('a').first.to_fuzzy_hash.should == {href: "/some_prefix/image_name.png"}
      doc.css('a img').first.to_fuzzy_hash.should == {src: "/some_prefix/image_name.thumb.png"}

      doc.css('a').last.to_fuzzy_hash.should == {href: "/some_prefix/image_name2.png"}
      doc.css('a img').last.to_fuzzy_hash.should == {src: "/some_prefix/image_name2.icon.png"}

      doc.css('img').size.should == 4
    end

    it "simplifyed syntax for image boxes should be robust (from error)" do
      html = "!![img] " # without resolved reference
      lambda{process(html)}.should_not raise_error
    end
  end

  # discarded
  # it "clear div" do
  #   html = "[clear]"
  #
  #   doc = to_xhtml html
  #   doc.css('div.clear').size.should == 1
  # end

  # discarded
  # it "space div" do
  #   html = "[space]"
  #
  #   doc = to_xhtml html
  #   doc.css('div.space').size.should == 1
  # end

  # discarded
  # it "should skip empty paragraphs" do
  #   html = "line 1\n\nline 2\n\n\n\nline 3"
  #   process(html).should =~ /<p>\s*line 1<\/p>\n<p>line 2<\/p>\n<p>line 3\s*<\/p>.?/
  # end
end