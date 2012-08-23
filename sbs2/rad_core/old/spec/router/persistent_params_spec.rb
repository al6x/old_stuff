require 'spec_helper'

describe "Persistent Params" do
  after :all do
    remove_constants %w(PathParamsRouter)
  end

  before do
    @router = Rad::Router.new :class

    @params = Rad::Conveyors::Params.new
    @router.stub(:safe_workspace).and_return({params: @params}.to_openobject)

    @router.persistent_params << :l
  end

  describe 'Basics' do
    it "global persistent params" do
      @params.merge! l: 'ru', id: 1

      @router.encode(Object, :send).should == ["/object/send", {l: 'ru'}]
      @router.encode(Object, :send, l: 'en').should == ["/object/send", {l: 'en'}]
    end

    it "should persist params with begining underscore" do
      @params.merge! _space: 'space_id', id: 1

      @router.encode(Object, :send).should == ['/object/send', {}]

      @router.persist_params do
        @router.encode(Object, :send).should == ["/object/send", {_space: 'space_id'}]
        @router.encode(Object, :send, _space: 'another_id').should == ["/object/send", {_space: 'another_id'}]
      end
    end
  end

  describe "Miscellaneous checks" do
    it "should not persist special params" do
      @params.merge! _method: 'get'

      @router.persist_params do
        @router.encode(Object, :send).should == ["/object/send", {}]
      end
    end
  end

  it "should correctly works when params are encoded in url path" do
    class PathParamsRouter
      def encode klass, method, params
        [%(#{klass.name}/#{method}#{'/' unless params.empty?}#{params.to_a.collect{|k, v| "#{k}/#{v}"}.join('/')}), {}]
      end

      def decode path, params
      end
    end

    router = Rad::Router.new :class, [[:prefix_router, PathParamsRouter.new]]
    router.persistent_params << :l
    params = Rad::Conveyors::Params.new
    params.l = 'en'
    router.stub(:safe_workspace).and_return({params: params}.to_openobject)

    router.encode(Object, :send).should == ["Object/send/l/en", {}]
  end
end