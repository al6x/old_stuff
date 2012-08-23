require 'spec_helper'

describe "Http basics" do
  with_prepare_params
  inject :environment, :conveyors

  isolate :conveyors

  before do
    rad.conveyors.web do |web|
      web.use Rad::Http::Processors::HttpWriter
      web.use Rad::Http::Processors::PrepareParams
      web.use Rad::Http::Processors::EvaluateFormat
    end
  end

  it "http call" do
    workspace = nil

    rad.http.call Rad::Http::Request.stub_environment do |c|
      c.call
      workspace = rad.workspace
    end
    # .should == [200, {"Content-Type" => "text/html"}, ""]

    workspace.delete(:env).should be_a(Hash)
    expected_result = {path: "/", response: [200, {"Content-Type" => "text/html"}, ""], params: {format: 'html'}}
    workspace.to_hash.subset(expected_result.keys).should == expected_result
  end
end