require 'controllers/spec_helper'

describe "Files" do
  with_bag_controller{Bag::Files}
  login_as :manager
  
  before do    
    # set_default_space
    # 
    # @user = Factory.create :manager
    # login_as @user      
    
    @container = Factory.create :folder
  end
    
  it "should create new file" do
    call :create, container_id: @container.to_param, collection: 'files', format: 'js', file: {file_file_name: 'test_file'}
    response.should be_ok
    
    IFile.count.should == 1
    IFile.first.file_file_name.should == 'test_file'
    
    @container.reload
    @container.files.size.should == 1
  end
  
  it "should update file" do
    @file = Factory.create :file
    call :update, id: @file.to_param, container_id: @container.to_param, format: 'js', file: {file_file_name: 'test_file2'}
    response.should be_ok
    
    IFile.count.should == 1
    IFile.first.file_file_name.should == 'test_file2'
  end
  
  it "should destroy file" do
    @file = Factory.create :file
    call :destroy, id: @file.to_param, container_id: @container.to_param, format: 'js'
    response.should be_ok
    
    IFile.count.should == 0
    @container.reload
    @container.files.size.should == 0
  end
end