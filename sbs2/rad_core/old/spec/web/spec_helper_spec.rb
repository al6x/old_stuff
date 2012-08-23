require 'spec_helper'

describe "spec helper" do
  isolate :conveyors, :router, before: :all

  before do
    rad.web
    load 'rad/profiles/web.rb'

    class ::Planes
      inherit Rad::Controller::Http

      def fly
        render inline: 'all right'
      end
    end
  end

  after :all do
    remove_constants :Planes
  end

  describe 'wcall' do
    before do
      rad.router.routers = [
        [:simple_router, Rad::Router::SimpleRouter.new]
      ]
    end

    it "basic usage" do
      wcall(Planes, :fly).should =~ /all right/
      wcall('/planes/fly').should =~ /all right/
    end

    it "with :cycle scope" do
      wcall(Planes, :fly){|c|
        c.call
      }.should =~ /all right/
    end

    describe "set_wcall" do
      before :all do
        set_wcall controller: Planes
      end

      it "usage with handy shortcut" do
        wcall(:fly).should =~ /all right/
      end
    end
  end

  describe "routes" do
    before do
      router = rad[:router]
      router.routers[:restful_router] = Rad::Router::RestfulRouter.new
      router.routers[:restful_router].add :planes, class_name: 'Planes'
    end

    it "build_url, build_url_path" do
      build_url(Planes, :fly).should == "/planes/fly"
      build_url_path("/path", key: 'value').should == "/path?key=value"
    end

    it "named routes" do
      fly_planes_path.should == "/planes/fly"
    end
  end
end