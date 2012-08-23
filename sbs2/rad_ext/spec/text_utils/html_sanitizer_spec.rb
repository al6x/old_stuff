require 'text_utils/spec_helper'

describe "HtmlSanitizer" do
  include RSpec::TextUtilsHelper

  before do
    @processor = TextUtils::HtmlSanitizer.new
    @options = {format: :html}
  end

  it_should_behave_like 'text processor'

  it "should escape restricted tags" do
    %w(script object).each do |tag|
      html = "<#{tag}}>some text</#{tag}>"
      process(html).should_not include(tag)
    end
  end

  it "shouldn't escape non-restricted tags" do
    common_attr_names = %w(class style)
    {
      iframe: %w(height scrolling src width),
      a:      %w(href title rel)
    }.each do |tag, attr_names|
      attrs = {}; (common_attr_names + attr_names).each{|n| attrs[n] = 'value'}

      attrs_html = ""; attrs.each{|n, v| attrs_html << "#{n}='#{v}'"}
      html = "<#{tag} #{attrs_html}}>some text</#{tag}>"

      to_xhtml(html).css(tag.to_s).first.to_fuzzy_hash.should == attrs
    end
  end

  it "should allow image inside of link (from error)" do
    html = <<HTML
<a rel="images" class="image_box" href="/some_image">
  <img src="/some_image"/>
</a>
HTML

    doc = to_xhtml html
    doc.css('a').first.to_fuzzy_hash.should == {href: "/some_image", class: "image_box"}
    doc.css('a img').first.to_fuzzy_hash.should == {src: "/some_image"}
  end

  it "should allow 'a' elements (from error)" do
    html = <<HTML
<a href="http://www.some.com/some">Absolute Link</a>
<a href="/some">Relative Link</a>
HTML

    doc = to_xhtml html
    doc.css("a").first[:href].should == "http://www.some.com/some"
    doc.css("a").last[:href].should == "/some"
  end

  it "should allow div with any classes (from error)" do
    html = %{<div class="col3 left"><a href='#'>text</a></div>}
    to_xhtml(html).css("div.col3.left a").size.should == 1
  end

#   Outdated
#   it "should embed iframe" do
#     html =<<HTML
# <object width="425" height="344">
# <param name="movie" value="http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&"></param>
# <param name="allowFullScreen" value="true"></param>
# <param name="allowscriptaccess" value="always"></param>
# <embed src="http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed>
# </object>
# HTML
#
#     doc = to_xhtml html
#     obj = doc.css("object").first.to_fuzzy_hash.should == {width: '425', height: '344'}
#     p1, p2, p3, embed = doc.css('object *')
#     p1.to_fuzzy_hash.should == {name: 'movie', value: 'http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&'}
#     p2.to_fuzzy_hash.should == {name: 'allowFullScreen', value: 'true'}
#     p3.to_fuzzy_hash.should == {name: 'allowscriptaccess', value: 'always'}
#     embed.to_fuzzy_hash.should == {
#       src: 'http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&',
#       type: 'application/x-shockwave-flash',
#       allowscriptaccess: 'always',
#       allowfullscreen: 'true',
#       width: '425',
#       height: '344'
#     }
#   end
end