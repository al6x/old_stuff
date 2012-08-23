require 'spec_helper'

describe "Routing Helper" do
  before :all do
    class ::BlogsController
      include Rad::Router::CoreRoutingHelper

      def show; end
    end
  end

  after :all do
    remove_constants %w(BlogsController)
  end

  before do
    @router = Rad::Router.new :class

    @params = Rad::Conveyors::Params.new
    @router.stub(:safe_workspace).and_return({params: @params}.to_openobject)

    @controller = BlogsController.new
    @controller.stub(:router).and_return(@router)
  end

  it "basic" do
    @router.stub(:encode_method).and_return([BlogsController, :show])
    @controller.show_blogs_path.should == "/blogs_controller/show"
  end

  it "correct works if there's no route" do
    lambda{@controller.undefined_path}.should raise_error(/no route for/)
    lambda{@controller.show_blogs}.should raise_error(/undefined method/)
  end

  it "argument parsing" do
    @router.stub(:encode_method).and_return([BlogsController, :show])

    @controller.show_blogs_path.should == "/blogs_controller/show"
    @controller.show_blogs_path(a: 'b').should == "/blogs_controller/show?a=b"
    @controller.show_blogs_path(10, a: 'b').should == "/blogs_controller/show?a=b&id=10"
  end

  it "helper_method should take any object as :id" do
    class IdStub
      def to_param
        'some_id'
      end
    end

    @router.stub(:encode_method).and_return([BlogsController, :show])
    @controller.show_blogs_path(IdStub.new, a: 'b').should == "/blogs_controller/show?a=b&id=some_id"
  end
end