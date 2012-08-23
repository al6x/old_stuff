# encoding: utf-8

require 'spec_helper'

describe "File Model" do
  with_file_model

  before :all do
    class ImageFile
      inherit FileModel

      def process &block
        block.call original if original
      end

      version :icon do
        def process &block
          block.call original if original
        end
      end

      def build_path name, version = nil
        '/storage/images' + build_standard_path(name, version)
      end

      def build_url name, version = nil
        '/images' + build_standard_url(name, version)
      end

      def build_name name
        name.gsub '+', ' '
      end

      def run_validations
        errors << 'invalid name' if original and original.name =~ /invalid/
      end
    end
  end
  after(:all){remove_constants :ImageFile, :AvatarFile}

  before do
    @file = "#{spec_dir}/ship.jpg".to_file
  end

  it "CRUD" do
    # blank
    image = ImageFile.new
    image.name.should be_nil
    image.file.should be_nil
    image.url.should == nil
    image.icon.file.should be_nil
    image.icon.url.should == nil

    # preserving
    image.original = @file
    image.original.name.should == 'ship.jpg'
    image.original.path.should == "#{spec_dir}/ship.jpg"

    image.name.should be_nil
    image.file.should be_nil
    image.url.should == nil

    image.icon.original.should == image.original
    image.icon.name.should be_nil
    image.icon.file.should be_nil
    image.icon.url.should == nil

    # writing
    image.save.should be_true
    image.name.should == 'ship.jpg'
    image.file.name.should == 'ship.jpg'
    image.file.path.should == "/storage/images/ship.jpg"
    image.file.exist?.should be_true
    image.url.should == '/images/ship.jpg'

    image.icon.name.should == 'ship.jpg'
    image.icon.file.name.should == 'ship.icon.jpg'
    image.icon.file.path.should == "/storage/images/ship.icon.jpg"
    image.icon.file.exist?.should be_true
    image.icon.url.should == '/images/ship.icon.jpg'

    # reading
    image = ImageFile.new
    image.read 'ship.jpg'
    image.name.should == 'ship.jpg'

    image.file.name.should == 'ship.jpg'
    image.file.path.should == "/storage/images/ship.jpg"
    image.file.exist?.should be_true
    image.url.should == '/images/ship.jpg'

    image.name.should == 'ship.jpg'
    image.icon.file.name.should == 'ship.icon.jpg'
    image.icon.file.path.should == "/storage/images/ship.icon.jpg"
    image.icon.file.exist?.should be_true
    image.icon.url.should == '/images/ship.icon.jpg'

    # updating
    image.original = "#{spec_dir}/ship2.jpg".to_file
    image.original.name.should == 'ship2.jpg'
    image.original.path.should == "#{spec_dir}/ship2.jpg"

    image.save.should be_true

    file_model_storage['storage/images/ship.jpg'].exist?.should be_false
    file_model_storage['storage/images/ship.icon.jpg'].exist?.should be_false

    image.name.should == 'ship2.jpg'
    image.file.name.should == 'ship2.jpg'
    image.file.path.should == "/storage/images/ship2.jpg"
    image.file.exist?.should be_true
    image.url.should == '/images/ship2.jpg'

    image.icon.name.should == 'ship2.jpg'
    image.icon.file.name.should == 'ship2.icon.jpg'
    image.icon.file.path.should == "/storage/images/ship2.icon.jpg"
    image.icon.file.exist?.should be_true
    image.icon.url.should == '/images/ship2.icon.jpg'

    # deleteing
    image = ImageFile.new
    image.read 'ship2.jpg'
    image.delete
    file_model_storage['storage/images/ship2.jpg'].exist?.should be_false
    file_model_storage['storage/images/ship2.icon.jpg'].exist?.should be_false
  end

  it "should preserve spaces and unicode characters in filename" do
    image = ImageFile.new
    image.original = "#{spec_dir}/файл с пробелами.txt".to_file
    image.save.should be_true
    image.url.should =~ /\/файл с пробелами\.txt/
    image.file.path.should =~ /\/файл с пробелами\.txt/
  end

  it "should escape + sign" do
    image = ImageFile.new
    image.original = "#{spec_dir}/file+name.txt".to_file
    image.save.should be_true
    image.url.should =~ /\/file name\.txt/
    image.file.path.should =~ /\/file name\.txt/
  end

  it 'should raise error if file not exists' do
    image = ImageFile.new
    -> {image.original = "#{spec_dir}/non existing file.jpg".to_file}.should raise_error(/not exist/)
  end

  it 'should validate and not save invalid files' do
    image = ImageFile.new
    image.original = "#{spec_dir}/ship.jpg".to_file
    image.valid?.should be_true

    image.original = "#{spec_dir}/invalid.txt".to_file
    image.valid?.should be_false
    image.errors.should == ['invalid name']

    image.save.should be_false
    image.errors.should == ['invalid name']
  end
end