require "spec_helper"

describe "Prepare Model" do
  before do
    class AModel
      def self.by_id! id
        id.should == 'some_id'
        new
      end
    end
  end
  after{remove_constants :AModel, :AController}

  it "should prepare model" do
    class AController
      inherit Rad::Controller, Controllers::PrepareModel

      prepare_model AModel

      def action
        @a_model.class.should == AModel
        :ok
      end
    end

    c = AController.new
    c.stub!(:params).and_return id: 'some_id'
    c.action.should == :ok
  end
end