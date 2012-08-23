require "spec_helper"

describe "Sites" do
  before do
    @theme = 'default'
    @layouts = {
      home:  :default, 
      style: :default, 
      blog:  :default, 
      post:  :default
    }
  end
  
  it_should_behave_like "site demo"
end