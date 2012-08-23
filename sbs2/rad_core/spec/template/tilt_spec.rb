# encoding: utf-8
require 'spec_helper'

describe "Tilt" do
  with_view_path spec_dir

  before_all do
    class TmpContext < Rad::Template::Context
      def tag name, content = nil, &block
        if block_given?
          content = capture(&block)
          concat "<#{name}>#{content}</#{name}>"
        else
          content = content
          "<#{name}>#{content}</#{name}>"
        end
      end
    end
  end
  after_all{remove_constants :TmpContext, :TextFormContext}

  old_mode = nil
  before do
    old_mode = rad.mode
    rad.mode = :development, true
  end
  after{rad.mode = old_mode, true}

  def render *a, &b
    rad.template.render *a, &b
  end

  it "should be able to specify ugliness" do
    rad.template.stub!(:ugly?).and_return true
    render('/ugly.haml').should == <<-HTML
<div class='a'>
<div class='b'>
content
</div>
</div>
HTML

    rad.template.stub!(:ugly?).and_return false
    render('/ugly.haml').should == <<-HTML
<div class='a'>
  <div class='b'>
    content
  </div>
</div>
HTML
  end

  it "should correctly show error lines" do
    lambda{render('/errors.erb')}.should raise_error(/line with error/){|e| e.backtrace.first.should =~ /^.+errors\.erb:2.+$/}
    lambda{render('/errors.haml')}.should raise_error(/line with error/){|e| e.backtrace.first.should =~ /^.+errors\.haml:2.+$/}
  end

  it "concat & capture" do
    render('/concat_and_capture.erb').should == "a captured_b"
    render('/concat_and_capture.haml').should == "a\ncaptured_b\n"
  end

  it "yield" do
    render('/yield.erb'){|variable| "content for :#{variable}"}.should == "Layout, content for :content"
  end

  it "should render non-ASCII symbols (from error)" do
    render('/encoding/erb').should =~ /»/
    render('/encoding/haml').should =~ /»/
  end

  describe "mixed template types" do
    it "broken haml concat (from error)" do
      render(
        '/mixed_templates/broken_haml_concat_haml',
        context: TmpContext.new
      ).gsub("\n", "").should == "<div>some content</div>"

      render(
        '/mixed_templates/broken_haml_concat_erb',
        context: TmpContext.new
      ).gsub("\n", "").should == "<div>some content</div>"
    end

    it "broken erb concat (from error)" do
      render(
        '/mixed_templates/broken_erb_concat_erb',
        context: TmpContext.new
      ).gsub("\n", "").should == "haml content<div>\tsome content</div>"
    end
  end

  it "nested capture & concat (from error)" do
    class TextFormContext < TmpContext
      def form_tag &block
        html = capture &block
        concat(tag(:form_tag, html))
      end

      def form_field &block
        html = capture &block
        concat(tag(:form_field, html))
      end
    end

    render('/nested_capture_and_concat', context: TextFormContext.new).gsub("\n", '').should ==
      "<form_tag><form_field>some field</form_field></form_tag>"
  end
end