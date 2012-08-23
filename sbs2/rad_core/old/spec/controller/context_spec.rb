require 'spec_helper'

describe "Controller Context" do
  with_view_path "#{spec_dir}/views"

  before :all do
    class ItemSpec
      inherit Rad::Controller::Abstract

      def show; end
      def update; end
      def delete; end
      def increase; end
      def decrease; end
    end

    class PageSpec < ItemSpec
      def show; end
      def increase; end
    end

    module NamespaceSpec
      class ClassSpec
        inherit Rad::Controller::Abstract

        def show; end
        def update; end
      end
    end
  end

  after :all do
    remove_constants %w(
      ItemSpec
      PageSpec
      NamespaceSpec
      ItemSpecHelper
      PageSpecHelper
    )
  end

  describe "basic" do
    before{@args = [[''], nil, nil, nil]}

    it "should return nil for non-existing template" do
      ItemSpec.find_relative_template(:delete, *@args).should be_nil
      PageSpec.find_relative_template(:delete, *@args).should be_nil
    end

    it "should provide template name for existing template" do
      ItemSpec.find_relative_template(:update, *@args).should == "#{spec_dir}/views/item_spec/update.erb"
    end

    it "should inherit template name for template existing in parent" do
      PageSpec.find_relative_template(:update, *@args).should == "#{spec_dir}/views/item_spec/update.erb"
    end

    it "should override template name for template existing in both self and parent" do
      ItemSpec.find_relative_template(:show, *@args).should == "#{spec_dir}/views/item_spec/show.erb"
      PageSpec.find_relative_template(:show, *@args).should == "#{spec_dir}/views/page_spec/show.erb"
    end

    it "should transfer namespaces into folders" do
      NamespaceSpec::ClassSpec.find_relative_template(:show, *@args).should == "#{spec_dir}/views/NamespaceSpec/ClassSpec/show.erb"
    end
  end

  describe "actions" do
    before{@args = [[''], nil, nil, nil]}

    it "should be able to check for action inside of actions.xxx files" do
      ItemSpec.find_relative_template(:increase, *@args).should == "#{spec_dir}/views/item_spec/actions.erb"
    end

    it "should be able to check for action inside of actions.xxx files" do
      ItemSpec.find_relative_template(:increase, *@args).should == "#{spec_dir}/views/item_spec/actions.erb"
      ItemSpec.find_relative_template(:decrease, *@args).should == "#{spec_dir}/views/item_spec/actions.erb"
      ItemSpec.find_relative_template(:action_not_defined_inside_of_actions_file, *@args).should == nil
    end

    it "should inherit actions.xxx" do
      PageSpec.find_relative_template(:increase, *@args).should == "#{spec_dir}/views/item_spec/actions.erb"
      PageSpec.find_relative_template(:decrease, *@args).should == "#{spec_dir}/views/page_spec/actions.erb"
    end
  end

  describe "context_class, helper" do
    before do
      ItemSpec.instance_variable_set "@context_class", nil
      ItemSpec.instance_variable_set "@context_class", nil
    end

    it "context_class" do
      ItemSpec.context_class.should == ItemSpec::ItemSpecContext
      PageSpec.context_class.should == PageSpec::PageSpecContext
      PageSpec::PageSpecContext.is?(PageSpec::ItemSpecContext).should be_true
    end

    it "helper" do
      module ::ItemSpecHelper
        def controller_item; end
      end

      module ::PageSpecHelper
        def controller_page; end
      end

      ItemSpec.helper ItemSpecHelper
      PageSpec.helper PageSpecHelper

      ItemSpec::ItemSpecContext.instance_methods.should include(:controller_item)

      PageSpec::PageSpecContext.instance_methods.should include(:controller_item)
      PageSpec::PageSpecContext.instance_methods.should include(:controller_page)
    end
  end

  describe "other" do
    it "should understand underscored paths" do
      NamespaceSpec::ClassSpec.find_relative_template(:update, [''], nil, nil, nil).should == "#{spec_dir}/views/namespace_spec/class_spec/update.erb"
    end
  end
end