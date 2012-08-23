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
end