require 'spec_helper'

describe "Attachments" do
  with_models

  before :all do
    class TheBaseFile < Models::Files::Base
    end

    class TheFile
      inherit Mongo::Model, Mongo::Model::FileModel
      collection :the_files

      mount_file :file, TheBaseFile
    end

    class ThePost
      inherit Mongo::Model
      collection :the_posts

      def files; @files ||= [] end
      mount_attachments(:files, :file){TheFile.new}

      def sorted_files
        files.sort{|a, b| a.file.file.name <=> b.file.file.name}
      end
    end
  end
  after(:all){remove_constants :ThePost, :TheFile, :TheBaseFile}

  before do
    @a = File.open("#{spec_dir}/v1/a.txt")
    @b = File.open("#{spec_dir}/v1/b.txt")
    @a_v2 = File.open("#{spec_dir}/v2/a.txt")
  end
  after do
    @a.close if @a
    @b.close if @b
    @a_v2.close if @a_v2
  end

  def post_with_two_files
    params = {
      files_as_attachments: [@a, @b]
    }

    post = ThePost.new params
    post.save!
    post.reload
    post.files.size.should == 2
    post
  end

  it "should add files" do
    post = post_with_two_files

    post.files.size.should == 2
    a, b = post.sorted_files
    a.file.file.path.should =~ /\/a\.txt/
    b.file.file.path.should =~ /\/b\.txt/
  end

  it "should remove files" do
    post = post_with_two_files
    a, b = post.sorted_files
    File.should exist(file_model_storage.path + b.file.file.path)

    params = {
      files_as_attachments: ['a.txt']
    }
    post.set(params).save!
    post.reload

    post.files.size.should == 1
    post.files.first.file.file.path.should =~ /\/a\.txt/

    # should also remove physical file
    File.should_not exist(file_model_storage.path + b.file.file.path)
  end

  it "should update files" do
    post = post_with_two_files

    params = {
      files_as_attachments: [@a_v2, 'b.txt']
    }

    post.set(params).save!
    post.reload

    a, b = post.sorted_files
    a.file.file.path.should =~ /\/a\.txt/
    File.read(file_model_storage.path + a.file.file.path).should == 'a v2'
    b.file.file.path.should =~ /\/b\.txt/
  end

  it "should provide :files_as_attachments getter" do
    post = post_with_two_files
    a, b = post.sorted_files

    post.files_as_attachments.should == [
      {name: 'a.txt', url: a.file.url},
      {name: 'b.txt', url: b.file.url}
    ]
  end
end