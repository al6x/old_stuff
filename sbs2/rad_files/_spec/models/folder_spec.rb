require 'models/spec_helper'

describe "Folder" do
  with_models before: :all
  login_as :auser
  
  before do 
    # set_default_space    
    # 
    # @user = Factory.create :user, name: 'auser'
    # login_as @user
    
    @folder = Factory.create :folder, name: 'folder'
  end
  
  def create_folder_with_file opt = {}
    @file = Factory.create(:file, {file_file_name: 'fname', dependent: true}.merge(opt)) #used_only_in_container: true
    @folder.files << @file
    @folder.save!
    @file.reload
  end
  
  it "should create and embed file" do
    create_folder_with_file
    
    @folder.files.size.should == 1
    @folder.files.first.file.file_name.should == 'fname'
  end
  
  it "should update embedded file" do
    create_folder_with_file
    
    @file.file_file_name = 'updated name'
    @file.save!
    
    @folder.reload
    @folder.files.size.should == 1
    @folder.files.first.file.file_name.should == 'updated name'
  end
  
  it "should destroy embedde file" do
    create_folder_with_file
    
    @file.destroy
    
    @folder.reload
    @folder.files.size.should == 0
  end
  
  it "files should be destroyed if folder destroyed" do
    create_folder_with_file
    
    @folder.destroy
    
    IFile.count.should == 0
  end
  
  describe "Embedding Folder into Page" do    
    def embed_into_page
      create_folder_with_file
      @folder.dependent!
      @folder.save!
      
      @page = Factory.create :page
      @page.items << @folder
      @page.save!
      @folder.save!
      
      @page.reload
      @folder.reload
    end
    
    it "should embed into Page" do
      embed_into_page      
      
      @page.items.first.name.should == 'folder'
      @page.items.first.files.first.file.file_name.should == 'fname'
    end
    
    it "should update files in embedded folder" do
      embed_into_page
      
      @file.file_file_name = 'fname2'
      @file.save
      
      @page.reload
      @page.items.first.files.first.file.file_name.should == 'fname2'
    end
    
    it "should delete all Folder and Files if Page deleted" do
      embed_into_page
            
      @page.destroy
      Folder.count.should == 0
      IFile.count.should == 0
    end
  end
end