require 'spec_helper'

describe 'task' do
  with_controllers
  set_controller Controllers::Tasks

  before do    
    @user = Factory.create :manager
    login_as @user
  end  

  %w{standalone embedded}.each do |mode|
    describe "(:#{mode}," do
      if mode == 'embedded'
        before do 
          @page = Factory.create :page
          @page_param = @page.to_param
        end
      end
          
      %w{js json}.each do |format|        
        next if format == 'json' and mode == 'embedded'
        
        describe ":#{format})" do

          it "state" do
            task = Factory.create :task
            task.state.should == 'active'
            call :state, id: task.to_param, event: 'finish', format: format, container_id: @page_param
            response.should be_ok
            task.reload
            task.should be_finished
          end
          
        end
      end
    end
  end

end