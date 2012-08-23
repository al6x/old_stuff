require 'spec_helper'

describe "Environment basic spec" do
  with_load_path "#{spec_dir}/path1", "#{spec_dir}/path2"

  before_all do
    @path1, @path2 = "#{spec_dir}/path1", "#{spec_dir}/path2"
  end

  describe 'files' do
    it "find_files?" do
      rad.environment.file_exist?('/some_folder/some_file').should be_true
      rad.environment.file_exist?('/file1').should be_true
    end

    it "find_file" do
      lambda{rad.environment.find_file('/some_folder/some_file')}.should raise_error(/Found multiple files/)
      rad.environment.find_file('/file1').should == "#{@path1}/file1"
      lambda{rad.environment.find_file('file1')}.should raise_error(AssertionError)
    end

    it "find_files" do
      rad.environment.find_files('/some_folder/some_file').sort.should == ["#{@path1}/some_folder/some_file", "#{@path2}/some_folder/some_file"]
    end

    it "find_files_by_pattern" do
      rad.environment.find_files_by_pattern('/*/some_file').sort.should == ["#{@path1}/some_folder/some_file", "#{@path2}/some_folder/some_file"]
    end
  end

  describe 'config' do
    it "smoke test" do
      rad.config
    end
  end
end