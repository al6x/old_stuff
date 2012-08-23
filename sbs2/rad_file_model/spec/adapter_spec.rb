# encoding: utf-8

require 'spec_helper'

describe "File Model" do
  with_file_model

  it 'should accept different formats' do
    original = FileModel::Adapter.new("#{spec_dir}/file.txt").to_file
    original.name.should == 'file.txt'
    original.read.should == "text"

    original = FileModel::Adapter.new("#{spec_dir}/file.txt".to_file).to_file
    original.name.should == 'file.txt'
    original.read.should == "text"

    File.open "#{spec_dir}/file.txt" do |f|
      original = FileModel::Adapter.new(f).to_file
      original.name.should == 'file.txt'
      original.read.should == "text"
    end

    File.open "#{spec_dir}/file.txt" do |f|
      original = FileModel::Adapter.new(filename: 'file.txt', tempfile: f).to_file
      original.name.should == 'file.txt'
      original.read.should == "text"
    end
  end

  it 'work with binary format' do
    File.open "#{spec_dir}/bos.jpeg" do |f|
      original = FileModel::Adapter.new(filename: 'bos.jpeg', tempfile: f).to_file
      original.name.should == 'bos.jpeg'
      original.size.should > 0
    end
  end
end