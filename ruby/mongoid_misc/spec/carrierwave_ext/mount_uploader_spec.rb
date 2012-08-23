require 'carrierwave_ext/spec_helper'

describe "Mongoid & CarrierWave" do   
  with_tmp_spec_dir
  before :each do
    connection = Mongo::Connection.new
    connection.db('test').collection('test').drop
    
    Mongoid.configure do |config|
      config.master = connection.db('test')
    end
  end
  
  before :all do
    class PlaneImageUploader < CarrierWave::Uploader::Base
      require 'carrierwave/processing/mini_magick'
  
      include CarrierWave::MiniMagick      
    
      storage :file
    
      version :icon do
        process convert: :png
        process resize_to_fit: [50, 50]
      end
    
      def store_dir
        PlaneImageUploader.store_dir
      end
    
      def root
        PlaneImageUploader.store_dir
      end
      
      class << self
        attr_accessor :store_dir
      end
    end        
  end
  after(:all){remove_constants :PlaneImageUploader}
  
  before do
    PlaneImageUploader.store_dir = "#{spec_dir}/data"
    @file = File.new "#{spec_dir}/plane.jpg"
  end
  after do 
    @file.close
    @file2.close if @file2
  end
  
  it "should works without model" do
    # writing
    uploader = PlaneImageUploader.new
    uploader.store!(@file)
    uploader.identifier.should == 'plane.jpg'
    uploader.url.should == '/plane.jpg'
    uploader.icon.url.should == '/plane.icon.jpg'
    File.should exist("#{spec_dir}/data/plane.icon.jpg")
    
    # reading
    uploader = PlaneImageUploader.new
    uploader.retrieve_from_store! 'plane.jpg'
    uploader.url.should == '/plane.jpg'
    uploader.icon.url.should == '/plane.icon.jpg'
    
    # destroying
    uploader = PlaneImageUploader.new
    uploader.retrieve_from_store! 'plane.jpg'
    uploader.remove!
    File.should_not exist("#{spec_dir}/data/plane.icon.jpg")
  end
  
  describe "Document" do
    before :all do
      class Plane
        include Mongoid::Document
  
        mount_uploader :image, PlaneImageUploader
      end        
    end
    after(:all){remove_constants :Plane}
  
    it "basic" do
      Plane.create! image: @file
      Plane.first.image.current_path.should =~ /\/plane.jpg/
      File.should exist("#{spec_dir}/data/plane.jpg")
    end
    
    it "path format" do
      Plane.create! image: @file
      
      plane = Plane.first
      plane.image.url.should == '/plane.jpg'
      plane.image.icon.url.should =~ /\/plane\.icon\.jpg/
      plane.image.name.should == 'plane.jpg'
    
      plane.image.icon.current_path.should =~ /\/plane\.icon\.jpg/
      File.should exist("#{spec_dir}/data/plane.icon.jpg")
    end
  end
  
  describe "EmbeddedDocument" do
    before :all do
      class PlaneImage
        include Mongoid::Document
        embedded_in :plane, class_name: 'Plane2'
        mount_uploader :image, PlaneImageUploader
      end
      
      class Plane2
        include Mongoid::Document
        
        embeds_many :images, class_name: 'PlaneImage'                
        mount_embedded_uploader :images, :image
      end        
    end
    after(:all){remove_constants :Plane2, :PlaneImage}
  
    it "basic" do
      Plane2.create! images: [PlaneImage.new(image: @file)]
      Plane2.first.images.first.image.current_path.should =~ /\/plane.jpg/
      File.should exist("#{spec_dir}/data/plane.jpg")
    end
    
    it "CRUD" do
      # create
      Plane2.create! images: [PlaneImage.new(image: @file)]      
      File.should exist("#{spec_dir}/data/plane.jpg")
      
      # update
      plane = Plane2.first
      @file2 = File.new "#{spec_dir}/plane2.jpg"      
      plane.images << PlaneImage.new(image: @file2)
      plane.save!
      File.should exist("#{spec_dir}/data/plane2.jpg")
      
      # destroy embedded
      plane.images.last.destroy
      File.should exist("#{spec_dir}/data/plane.jpg")
      File.should_not exist("#{spec_dir}/data/plane2.jpg")

      # destroy parent
      plane.destroy
      File.should_not exist("#{spec_dir}/data/plane.jpg")
    end
  
    it "path format" do
      Plane2.create! images: [PlaneImage.new(image: @file)]
      
      plane_image = Plane2.first.images.first
      plane_image.image.url.should == '/plane.jpg'
      plane_image.image.icon.url.should =~ /\/plane\.icon\.jpg/
    
      plane_image.image.icon.current_path.should =~ /\/plane\.icon\.jpg/
      File.should exist("#{spec_dir}/data/plane.icon.jpg")
    end
  end
end