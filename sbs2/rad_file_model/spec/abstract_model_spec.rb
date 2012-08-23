require 'spec_helper'
require 'file_model/spec/shared_crud'

describe 'Model Integration' do
  it_should_behave_like "file model crud"

  before :all do
    class ImageFile; end

    class TheModel < ModelStub
      inherit FileModel::Helper

      attr_accessor :name

      mount_file :image, ImageFile

      def attribute_get name
        instance_variable_get :"@#{name}"
      end
      def attribute_set name, value
        instance_variable_set :"@#{name}", value
      end

      before_validate.push -> _self {
        self.image.run_validations
        self.errors[:image] = image.errors unless image.errors.empty?
      }

      after_save.push -> _self {self.image.save}

      after_delete.push -> _self {self.image.delete}
    end
  end
  after(:all){remove_constants :TheModel}

  before{@model_class = TheModel}
end