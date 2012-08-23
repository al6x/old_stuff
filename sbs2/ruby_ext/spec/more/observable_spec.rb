require "spec_helper"

describe "Observable" do
  after{remove_constants :Tmp}

  it "method without parameters" do
    class Tmp
      include RubyExt::Observable
    end

    mock = mock "Observer"
    obs = Tmp.new
    obs.add_observer mock
    mock.should_receive(:update).with 2
    obs.notify_observers :update, 2
  end
end