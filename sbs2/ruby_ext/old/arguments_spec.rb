require "spec_helper"

describe 'Object' do
  after{remove_constants :Tmp}

  it "respond_to" do
    class Tmp
      def test; 2 end
    end

    o = Tmp.new
    o.respond_to(:not_exist).should be_nil
    o.respond_to(:test).should == 2
  end

  it "send_with_params" do
    class Tmp
      def show id = nil;        called :show, id end
      def update id;            called :update, id end
      def custom id, params;    called :custom, id, params end
      def objects format, *ids; called :objects, format, *ids end
    end

    o = Tmp.new
    [
      :show,    {id: 10},                      [10],
      :show,    {},                            [nil],
      :update,  {id: 10},                      [10],
      :custom,  {id: 10, a: 'b'},              [10, {id: 10, a: 'b'}],
      :objects, {format: 'json', ids: [1, 2]}, ['json', [1, 2]]
    ].each_slice 3 do |method_name, params, args|
      o.should_receive(:called).with *([method_name] + args)
      o.send_with_params method_name, params
    end

    # Special cases.
    -> {o.send_with_params :update, {}}.should raise_error(/missing.*id/)
  end
end