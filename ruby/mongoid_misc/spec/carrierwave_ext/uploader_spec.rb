# encoding: utf-8
require 'carrierwave_ext/spec_helper'
require 'carrierwave/processing/mini_magick'

describe "Uploading" do  
  with_tmp_spec_dir
  with_mongoid
  with_files  

  before :all do
    class ImageUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick

      # def sanitize_regexp
      #   /[^[:word:]\.\-\+\s_]/i
      # end

      def file_path
        model.id
      end

      def store_dir
        "#{root}#{file_path}"
      end

      def extension_white_list
        [/.*/]
      end
    end

    class Post
      include Mongoid::Document

      field :name, type: String, default: ""
      validates_uniqueness_of :name
  
      mount_uploader :image, ImageUploader
    end                
  end  
  after(:all){remove_constants :Post, :ImageUploader}  

  it "should upload images" do    
    post = nil
    File.open "#{spec_dir}/ship.jpg" do |f|
      post = Post.new image: f
      post.save!
    end
    post.image.url.should =~ /\/ship\.jpg/
    post.image_filename.should =~ /ship\.jpg/
    post.image.path.should =~ /\/ship\.jpg/
  end

  it "should preserve spaces and unicode characters in filename" do
    File.open "#{spec_dir}/файл с пробелами.txt" do |f|
      post = Post.new image: f

      post.image.url.should =~ /\/файл с пробелами\.txt/
      post.image.filename =~ /файл с пробелами\.txt/
      post.image.path =~ /\/файл с пробелами\.txt/
    end
  end
end