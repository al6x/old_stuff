require 'spec_helper'

describe "Abstract" do
  with_view_path "#{spec_dir}/views"
  with_abstract_controller

  after :all do
    remove_constants %w(
      SomeHelperSpec
      HelperSpec
      HelperMethodSpec
    )
  end

  it "helper_method" do
    class ::HelperMethodSpec
      inherit Rad::Controller::Abstract

      def some_controller_method
        "some controller value (rendered in cotext of #{self.class})"
      end
      helper_method :some_controller_method

      def action; end
    end

    ccall(HelperMethodSpec, :action).should == "some controller value (rendered in cotext of HelperMethodSpec)"
  end

  it "helper" do
    module ::SomeHelperSpec
      def wiget
        "some wighet (rendered in context of #{self.class.name})"
      end
    end

    class ::HelperSpec
      inherit Rad::Controller::Abstract

      helper SomeHelperSpec

      def action; end
    end

    ccall(HelperSpec, :action).should == "some wighet (rendered in context of HelperSpec::HelperSpecContext)"
  end
end