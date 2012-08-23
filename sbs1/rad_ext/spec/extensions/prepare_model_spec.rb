require "spec_helper_with_rad"

describe "User Error" do
  rad.web
  rad.reset :conveyors
  isolate :conveyors, before: :all

  before :all do    
    load 'spec_helper/web_profile.rb'
    
    class ::SomeModel
      def self.find! id
        id.should == 'some id'
        SomeModel.new
      end
    end
  end  
  after :all do
    remove_constants %w(SomeModel ControllerSpec)
  end
  
  it "user error" do
    class ::ControllerSpec
      inherit Rad::Controller::Http
      
      prepare_model SomeModel, id: :some_model, variable: 'some_model'
      
      def action
        @some_model.should_not == nil
        render inline: 'ok'
      end
    end

    ccall(ControllerSpec, :action, some_model: 'some id').should == 'ok'
  end
end