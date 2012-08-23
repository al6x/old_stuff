require 'spec_helper'

describe "Configurator" do
  before do
    @basic_router = Rad::Router::BasicRouter.new
    @router = Rad::Router.new(:class, [
      [:basic_router, @basic_router]
    ])
    Rad::Router::Configurator.stub(:router).and_return(@router)
  end

  it "named routes" do
    rad.router.configure do |config|
      config.stub(:router).and_return(@router)

      config.skip(/^\/favicon/)
    end

    @basic_router.skip_routes.size.should > 0
  end
end