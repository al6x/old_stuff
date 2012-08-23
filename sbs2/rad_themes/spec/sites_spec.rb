require "spec_helper"

describe "Sites" do
  before do
    @theme = 'simple_organization'
    @layouts = {
      home:  :home, 
      style: :default, 
      blog:  :default, 
      post:  :default
    }
  end
  
  it_should_behave_like "site demo"
end