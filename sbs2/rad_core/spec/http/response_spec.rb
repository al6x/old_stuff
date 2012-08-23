require 'spec_helper'

describe "Response" do
  before{@response = Rad::Http::Response.new}

  it "should take shortcuts to status codes" do
    @response.status = :error
    @response.status.should == 500

    @response.status = :ok
    @response.status.should == 200
  end

  it "format" do
    @response.format = 'js'
    @response.format.should == 'js'
    @response.content_type.should == "application/javascript"
  end
end