require 'spec_helper'

describe "Attachments" do
  with_models
  login_as :user

  before do
    @a = File.open("#{spec_dir}/a.txt")
  end
  after do
    @a.close if @a
  end

  it "smoke test" do
    item = factory.create :item, name: 'my note', attachments_as_attachments: [@a]
    item.reload

    item.attachments.size.should == 1
    item.attachments.first.file.file.path.should =~ /\/#{item._id}\/a\.txt/
  end
end