require File.dirname(__FILE__) + '/../spec_helper'

describe "TextUtils" do  
  before :each do
  end
  
  def to_doc markup
    Nokogiri::HTML(to_html(markup))
  end
  
  def to_html markup
    TextUtils.markup(markup)
  end
  
  ::Nokogiri::XML::Node.class_eval do
    def should_be_equal_to attributes
      attributes.stringify_keys!
      self.content.should == content if content = attributes.delete('content')
      
      attributes.each do |attr_name, value|
        self[attr_name].to_s.should == value.to_s
      end
    end
  end
  
  describe "MarkdDown" do
    it "should do basic markup" do
      doc = to_doc "**text**"
      doc.css("p b, p strong").first.should_be_equal_to :content => 'text'
    end
    
    it "should guess urls" do      
      doc = to_doc "This is a http://www.some.com/some link"
      doc.content.strip.should == "This is a http://www.some.com/some link"
      doc.css("p a").first.should_be_equal_to :href => "http://www.some.com/some"
      
      # from error
      doc = to_doc "http://www.some.com/some"
      doc.content.strip.should == "http://www.some.com/some"
      doc.css("p a").first.should_be_equal_to :href => "http://www.some.com/some"
      
      # from error
      # http://mastertalk.ru/topic111478.html
    end
    
    it "should allow 'a' elements" do
      html = <<HTML
<a href="http://www.some.com/some">Absolute Link</a>
<a href="/some">Relative Link</a>
HTML
      
      doc = to_doc html
      doc.css("a").first[:href].should == "http://www.some.com/some"
      doc.css("a").last[:href].should == "/some"
    end
    
    it "should embed YouTube Videos" do 
      html =<<HTML
<object width="425" height="344">
<param name="movie" value="http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&"></param>
<param name="allowFullScreen" value="true"></param>
<param name="allowscriptaccess" value="always"></param>
<embed src="http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed>
</object>
HTML

      doc = to_doc html      
      obj = doc.css("object").first.should_be_equal_to :width => 425, :height => 344
      p1, p2, p3, embed = doc.css("object *")
      p1.should_be_equal_to :name => "movie", :value => "http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&"
      p2.should_be_equal_to :name => "allowFullScreen", :value => "true"
      p3.should_be_equal_to :name => "allowscriptaccess", :value => "always"
      embed.should_be_equal_to :src => "http://www.youtube.com/v/s8hYKKXV5wU&hl=en_US&fs=1&", 
        :type => "application/x-shockwave-flash", :allowscriptaccess => "always",
        :allowfullscreen => "true", :width => "425", :height => "344"
    end
    
    it "should skip empty paragraphs" do
      html = "line 1\n\nline 2\n\n\n\nline 3"
      to_html(html).should =~ /<p> line 1<\/p>\n<p>line 2<\/p>\n<p>line 3 <\/p>.?/
    end
    
    it "should convert \n to <br/>" do
      to_doc("foo\nbar").css('br').size.should == 1
    end
    
    it "should not touch single underscores inside words" do
      to_html("foo_bar").should include("foo_bar")
    end
    
    it "should works with unicode" do
      html = %{Юникод <a href="http://www.some.com/" class="_image_box">Юникод</a>}
      doc = to_doc html
      doc.css('p').first.content.should =~ /Юникод/
      doc.css('p a').first.should_be_equal_to :href => "http://www.some.com/", :class => "_image_box", :content => "Юникод"
    end
    
    it 'should allow class and rel attribute' do
      html = %{<a href="http://www.some.com/" class="_image_box" rel="nofollow">Some</a>}
      doc = to_doc html
      doc.css('a').first.should_be_equal_to  :href => "http://www.some.com/", :class => "_image_box", :rel => "nofollow"
    end
    
    it "should allow image inside of link" do
      html = <<HTML
<a rel="article_images" class="_image_box" href="/some_image">
<img src="/some_image"></img>
</a>
HTML
    
      doc = to_doc html
      doc.css('a').first.should_be_equal_to :href => "/some_image", :class => "_image_box"
      doc.css('a img').first.should_be_equal_to :src => "/some_image"
    end
    
    it "should use simplifyed syntax for image boxes (!![img_thumb] => [![img_thumb]][img_full_version])" do
      html = <<HTML
!![img]
![img]

!![img_2]
![img_2]

[img]: /some_prefix/image_name.png
[img_2]: /some_prefix/image_name2.icon.png
HTML

      doc = to_doc html
      doc.css('a').first.should_be_equal_to :href => "/some_prefix/image_name.png"
      doc.css('a img').first.should_be_equal_to :src => "/some_prefix/image_name.thumb.png"
      
      doc.css('a').last.should_be_equal_to :href => "/some_prefix/image_name2.png"
      doc.css('a img').last.should_be_equal_to :src => "/some_prefix/image_name2.icon.png"
      
      doc.css('img').size.should == 4
    end
    
    it "simplifyed syntax for image boxes should be robust (from error)" do
      html = "!![img] " # without resolved reference
      to_html(html)
      lambda{to_html(html)}.should_not raise_error
    end
    
    it "should create teaser from text" do
      text = %{Hi    there, I have a page that will list news articles}
      TextUtils.truncate(text, 20).should == "Hi there, I have a ..."
    end
    
    it "should create teaser from html" do
      text = %{Hi    <div><b>there</b>, I have a page that will list news articles</div>}
      TextUtils.truncate(text, 20).should == "Hi there, I have a ..."
            
      TextUtils.truncate(%{a<br/>b}, 20).should == "a b" # from error
    end
    
    it "embed metaweb.com wiget" do
      html = <<HTML
<div itemtype="http://www.freebase.com/id/computer/software" itemid="http://www.freebase.com/id/en/google_web_toolkit" itemscope="" style="border: 0pt none; outline: 0pt none; padding: 0pt; margin: 0pt; position: relative;" id="fbtb-6ffc2545598340cbbc7945f43ebd45de" class="fb-widget">
    <iframe frameborder="0" scrolling="no" src="http://www.freebase.com/widget/topic?track=topicblocks_homepage&amp;mode=content&amp;id=%2Fen%2Fgoogle_web_toolkit" style="height: 285px; width: 413px; border: 0pt none; outline: 0pt none; padding: 0pt; margin: 0pt;" classname="fb-widget-iframe" allowtransparency="true" class=" "></iframe>
    <script defer="" type="text/javascript" src="http://freebaselibs.com/static/widgets/2/widget.js"></script>
</div>
HTML
      
      text = "{metaweb:google_web_toolkit}"
      to_html(text).should include(html)
    end
    
    it "should correctly insert newline (from error)" do
      html = <<HTML
![img] Open Design.
http://oomps.com

[img]: /some_link
HTML

      to_doc(html).css('br').size.should == 1
    end
    
    it "clear div" do
      html = "[clear]"
      
      doc = to_doc html
      doc.css('div.clear').size.should == 1
    end
    
    it "space div" do
      html = "[space]"
      
      doc = to_doc html
      doc.css('div.space').size.should == 1
    end

    it "should correctly guess links (from error)" do
      to_doc("http://some_domain.com http://some_domain.com").css('a').size == 2
    end
    
    it "should leave existing links intact" do
      doc = to_doc(%{<a href="http://some_domain.com">http://some_domain.com</a>})
      doc.css('a').size.should == 1
      doc.css('a').first['href'].should == "http://some_domain.com"
    end
    
    it "should leave existing links intact" do
      md = %{\
[Download Page][dl]
[dl]: http://www.mozilla.org/products/firefox/}

      to_doc(md).css('a').first['href'].should == 'http://www.mozilla.org/products/firefox/'
    end
    
    it "should allow div with any classes (from error)" do
      html = %{<div class="col3 left"><a href='#'>text</a></div>}
      to_doc(html).css("div.col3.left a").size.should == 1
    end
    
    it "should apply markup inside of html elements (from error)" do
      html = <<HTML
<div class='right'>
![img]
</div>

[img]: /some_link
HTML

      to_doc(html).css('.right img').size.should == 1
    end
    
    it "shouldn't create newline after > sign (from error)" do
      html = %{\
<div>text</div>
text}
      to_doc(html).css('br').size.should == 0
    end
    
    it "shouldn't add empty <p> before first line (from error)" do
      to_html("<span>text</span>text").should_not =~ /<p>\s*<\/p>/
    end
    
    it "should not aply markdown if document specified as [html]" do
      html = %{\
[html]
first line
**text**
second line}

      r = to_html(html)
      r.should_not include('<')
      r.should_not include('[html]')
    end
        
    it "should still escape input in [html] mode" do
      html = %{\
[html]
<script>some dangerous code</script>}

      to_html(html).should_not include('script')
    end
  end
end