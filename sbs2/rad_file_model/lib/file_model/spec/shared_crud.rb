require 'vos'
require 'file_model/spec'

shared_examples_for 'file model crud' do
  describe "file model crud" do
    with_file_model

    before :all do
      class ImageFile
        inherit FileModel

        def build_path name, version = nil
          "/storage/images/#{model.name}" + super
        end

        def build_url name, version = nil
          "/images/#{model.name}" + super
        end

        def run_validations
          errors << 'invalid name' if original and (original.name =~ /invalid/)
        end
      end
    end
    after(:all){remove_constants :ImageFile}

    before do
      @shared_dir = __FILE__.to_entry.parent.dir(:shared_crud).path
    end

    it 'CRUD' do
      # read
      model = @model_class.new
      model.name = 'sea'
      model.image.class.should == ImageFile
      model.image.url.should be_nil
      model.image.file.should be_nil

      # preserving
      file = "#{@shared_dir}/ship.jpg"
      model.image = file
      model.image.original.path.should == "#{@shared_dir}/ship.jpg"
      model.instance_variable_get(:@image).should == 'ship.jpg'
      model.image.url.should be_nil
      model.image.file.should be_nil

      # saving
      model.save.should be_true
      model.instance_variable_get(:@image).should == 'ship.jpg'
      model.image.url.should == '/images/sea/ship.jpg'
      model.image.file.path.should == "/storage/images/sea/ship.jpg"
      file_model_storage['storage/images/sea/ship.jpg'].exist?.should be_true

      # reading
      model = @model_class.new
      model.name = 'sea'
      model.instance_variable_set(:@image, 'ship.jpg')
      model.image.url.should == '/images/sea/ship.jpg'
      model.image.file.path.should == "/storage/images/sea/ship.jpg"

      # updating
      file2 = "#{@shared_dir}/ship2.jpg".to_file
      model.image = file2
      model.instance_variable_get(:@image).should == 'ship2.jpg'
      model.image.original.path.should == "#{@shared_dir}/ship2.jpg"
      model.image.url.should == '/images/sea/ship.jpg'
      model.image.file.path.should == "/storage/images/sea/ship.jpg"

      model.save.should be_true
      model.instance_variable_get(:@image).should == 'ship2.jpg'
      model.image.url.should == '/images/sea/ship2.jpg'
      model.image.file.path.should == "/storage/images/sea/ship2.jpg"
      file_model_storage['storage/images/sea/ship.jpg'].exist?.should be_false
      file_model_storage['storage/images/sea/ship2.jpg'].exist?.should be_true

      # deleteing
      model.delete.should be_true
      file_model_storage['storage/images/sea/ship2.jpg'].exist?.should be_false
    end

    it "should be able to submit errors and interrupt model saving" do
      file = "#{@shared_dir}/invalid.txt".to_file
      model = @model_class.new
      model.image = file
      model.image.should_not_receive(:save)
      model.save.should be_false
      model.errors[:image].should == ['invalid name']
    end
  end
end