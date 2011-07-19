require "spec_helper_with_rad"

describe "User Error" do
  rad.web
  rad.reset :conveyors
  
  isolate :conveyors, before: :all
  
  before(:all){load 'spec_helper/web_profile.rb'}
  
  after :all do
    remove_constants %w(UserErrorSpec)
  end
  
  it "user error" do
    class ::UserErrorSpec
      inherit Rad::Controller::Http
      
      def call
        raise_user_error "some error"
      end      
      
      protected
        def catch_user_error
          begin
            yield
          rescue UserError => ue
            render inline: "Catched #{ue.message}"
          end
        end
        around :catch_user_error
    end
    
    ccall(UserErrorSpec, :call).should == "Catched some error"
  end
end