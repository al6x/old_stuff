require 'text_utils/spec_helper'

describe "FormatQualifier" do
  before do
    @processor = TextUtils::FormatQualifier.new
  end

  it_should_behave_like 'text processor'

  it "should guess format" do
    [
      '<b>some</b>',                 :html,
      '<b>some</b> <p>other</p>',    :html,
      ' <b> some</b> ',              :html,
      '<b/>',                        :html,
      '<b>',                         :markdown,
      'abc',                         :markdown
    ].each_slice 2 do |text, format|
      env = {}
      @processor.call(text, env)
      env[:format].should == format
    end
  end

  it "should guess html format (from error)" do
    html = <<HTML
<h2>Title</h2>

<p>body</p>
HTML

    env = {}
    @processor.call(html, env)
    env[:format].should == :html
  end

end