# encoding: utf-8
require 'spec_helper'

describe "Uploading" do
  with_mongo_model
  with_file_model

  before :all do
    class TheFile < Models::Files::Base
    end

    class ThePost
      inherit Mongo::Model, Mongo::Model::FileModel
      collection :the_posts

      mount_file :file, TheFile
    end
  end
  after(:all){remove_constants :ThePost, :TheFile}

  it "should preserve spaces and unicode characters in filename" do
    File.open "#{spec_dir}/файл с пробелами.txt" do |f|
      post = ThePost.create! file: f

      post.file.url.should =~ /\/файл с пробелами\.txt/
      post.file.file.path =~ /файл с пробелами\.txt/
    end
  end
end