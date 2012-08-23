require 'html/spec_helper'

describe "ScopedParams" do
  it "basic" do
    workspace = Rad::Conveyors::Workspace.new.update(params: {"book[title]" => "Super Hero"})

    @processor = Rad::Html::Processors::ScopedParams.new(lambda{})
    @processor.stub(:workspace).and_return(workspace)
    @processor.call

    workspace.params.should == {
      book: {"title" => "Super Hero"}
    }
  end
end