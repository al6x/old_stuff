require 'text_utils/spec_helper'

describe "Truncate" do
  before do
    @processor = TextUtils::Truncate.new nil, 20
  end

  it_should_behave_like 'text processor'

  it "should truncate text" do
    text = %{Hi    there, I have a page that will list news articles}
    @processor.call(text, {format: :text}).should == "Hi there, I have a ..."
  end

  it "should truncate html" do
    text = %{Hi    <div><b>there</b>, I have a page that will list news articles</div>}
    @processor.call(text, {format: :html}).should == "Hi there, I have a ..."

    text = %{a<br/>b}
    @processor.call(text, {format: :html}).should == "a b" # from error
  end
end