require 'spec_helper'

describe "MiniMagic" do
  with_file_model

  before :all do
    class ImageFile
      inherit FileModel

      def process &block
        mini_magic block do |image|
          image.resize '150x150'
        end
      end

      version :icon do
        def process &block
          mini_magic block do |image|
            image.resize '50x50'
          end
        end
      end
    end
  end
  after(:all){remove_constants :ImageFile}

  before do
    @file = "#{spec_dir}/bos.jpg".to_file
  end

  it "resizing" do
    image = ImageFile.new
    image.original = @file
    image.save!

    image.file.size.should > image.icon.file.size
  end
end