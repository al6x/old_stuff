require 'spec'
require 'RubyExt/Localization/require'

module RubyExt
  module Spec
    describe "RubyExt::Localization" do
      before :each do
        RubyExt::Localization.default_language = "en"
        RubyExt::Localization.language = nil
      end

      it "Default Language" do
        ForLocalization::NS::B.new.message.should == "English"
        RubyExt::Localization.default_language = "ru"
        ForLocalization::NS::B.new.message.should == "Russian"
      end

      it "Not Localized" do
        RubyExt::Localization.default_language = "ru"
        ForLocalization::NS::B.new.not_localized.should == "English Not Localized"
      end
      
      it "Language set" do
        ForLocalization::NS::B.new.message.should == "English"
        RubyExt::Localization.language = lambda{"ru"}
        ForLocalization::NS::B.new.message.should == "Russian"
      end

			it "Language not set" do
				RubyExt::Localization.language = lambda{nil}
				ForLocalization::NS::B.new.message.should == "English"
			end

      it "Class Hierarchy" do
        RubyExt::Localization.language = lambda{"ru"}
        ForLocalization::NS::B.new.class_hierarchy_message.should == "Class Hierarchy Russian"
      end

      it "Namespace Hierarchy" do
        RubyExt::Localization.language = lambda{"ru"}
        ForLocalization::NS::B.new.namespace_hierarchy_message.should ==
          "Namespace Hierarchy Russian"
      end

      it "Substitution" do
        RubyExt::Localization.language = lambda{"ru"}
        ForLocalization::NS::B.new.substitution.should == "Russian 10"
      end
    end
  end
end
