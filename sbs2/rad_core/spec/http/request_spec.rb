require 'spec_helper'

describe "Request" do
  before do
    @rack_request = Rad::Http::RackRequest.new({})
    @request = Rad::Http::Request.new @rack_request
  end

  it "mapping parameters to method arguments"
  # do
  #   [
  #     {:'0' => 'a', :'1' => 'b'},                 ['a', 'b'],
  #     # :id always should be first if presented.
  #     {:'0' => 'a', :'1' => 'b', :id => 'id'},    ['id', 'a', 'b'],
  #     {:'0' => 'a', :b => 'b'},                   ['a', {b: 'b'}],
  #     # Should merge rest of options with last argument if it's a Hash.
  #     {:'0' => 'a', :'1' => {b: 'b'}, :c => 'c'}, ['a', {b: 'b', c: 'c'}]
  #   ].each_slice 2 do |params, args|
  #     @request.stub(:params).and_return params
  #     @request.args.should == args
  #   end
  # end

  it "format" do
    @request.format = 'js'
    @request.format.should == 'js'
  end
end