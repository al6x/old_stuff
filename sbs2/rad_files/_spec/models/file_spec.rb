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
    
  it "should create empty file" do
    IFile.create! name: 'file'
  end
  
  # it "should upload images" do
  #   f = nil
  #   File.open "#{@data_dir}/ship.jpg" do |data|
  #     f = IFile.create slug: 'data', file: data
  #   end
  #   f.file.should_not be_blank
  # end
  # 
  # it "shouldn't change original file name and should create resized thumbinail and icon version for images" do
  #   File.open "#{@data_dir}/ship.jpg" do |data|
  #     f = IFile.create slug: 'data', file: data
  #   
  #     f.smart_url.should =~ /files\/data\/ship.jpg\?\d+/    
  #     f.smart_url(:icon).should =~ /files\/data\/ship.icon.jpg\?\d+/
  #     f.smart_url(:thumb).should =~ /files\/data\/ship.thumb.jpg\?\d+/    
  #   end
  # end
  # 
  # it "shouldn't change original file name and should create resized mime thumbinail and icon version for recognized non-image types" do
  #   File.open "#{@data_dir}/ship.pdf" do |data|
  #     f = IFile.create slug: 'data', file: data
  #   
  #     f.smart_url.should =~ /files\/data\/ship.pdf\?\d+/    
  #     f.smart_url(:icon).should =~ /images\/mime\/pdf.icon\.png/
  #     f.smart_url(:thumb).should =~ /images\/mime\/pdf.thumb\.png/
  #   end
  # end
  # 
  # it "shouldn't change original file name and should create resized mime thumbinail and icon version for binary files" do
  #   File.open "#{@data_dir}/ship" do |data|
  #     f = IFile.create slug: 'data', file: data
  #   
  #     f.smart_url.should =~ /files\/data\/ship\?\d+/
  #     f.smart_url(:icon).should =~ /images\/mime\/dat.icon\.png/
  #     f.smart_url(:thumb).should =~ /images\/mime\/dat.thumb\.png/
  #   end
  # end
  # 
  # it "should preserve spaces in filename" do
  #   File.open "#{@data_dir}/file with spaces.txt" do |data|
  #     f = IFile.create slug: 'file with spaces', file: data
  #   
  #     f.smart_url.should =~ /files\/file with spaces\/file with spaces\.txt\?\d/
  #     # f.smart_url.should =~ /files\/data\/ship\?\d+/
  #     # f.smart_url(:icon).should =~ /images\/mime\/dat_icon\.png/
  #     # f.smart_url(:thumb).should =~ /images\/mime\/dat_thumb\.png/
  #   end
  # end
end