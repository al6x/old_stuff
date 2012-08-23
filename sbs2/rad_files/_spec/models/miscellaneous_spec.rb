require 'models/spec_helper'

describe "File" do      
  with_models before: :all
  login_as :auser
  
  before do     
    # set_default_space
    #   
    # @user = Factory.create :user, name: 'auser'
    # login_as @user
    
    @app_dir = File.expand_path "#{File.dirname __FILE__}/../.."        
    @data_dir = "#{@app_dir}/spec/data"
    
    File.delete_directory "#{rad.config.runtime_path!}/fs/#{Account.current.name}"
  end
  
  after do
    File.delete_directory "#{rad.config.runtime_path!}/fs/#{Account.current.name}"
  end
    
  it "should upload files" do
    IFile.enable_file_audit do
      File.open "#{@data_dir}/ship.jpg" do |data|
        f = IFile.create slug: 'data', file: data
      end
    end
    Account.current.files_size.should > 0
  end
  
  it "items should works correctly (from error)" do
    Note.enable_file_audit do
      Factory.create :note
    end
  end
end