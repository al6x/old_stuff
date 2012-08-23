require 'file_model'
require 'vos'

FileModel::ClassMethods.class_eval do
  def box; FileModel.box end
end

FileModel.metaclass_eval do
  attr_accessor :box
end

rspec do
  def file_model_storage
    '/tmp/file_model_test'.to_dir
  end

  class << self
    def with_file_model
      tmp = '/tmp/file_model_test'.to_dir

      before do
        tmp.delete.create
        FileModel.box = Vos::Box.new(Vos::Drivers::Local.new(root: tmp.path))
      end

      after{tmp.delete}
    end
  end
end