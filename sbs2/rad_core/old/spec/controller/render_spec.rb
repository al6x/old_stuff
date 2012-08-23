require 'spec_helper'

describe "Controller render" do
  with_view_path "#{spec_dir}/views"
  with_abstract_controller

  after :all do
    remove_constants %w(
      LayoutFiltersSpec
      LayoutSpec
      AnotherLayout
      ExplicitRenderSpec
      RenderInsideOfControllerSpec
      ForbidPartialAsActionSpec
      FormatSpec
      AlreadyRenderedSpec
      SpecialFormatSpec
      AnotherActionSpec
      InlineRenderSpec
      InlineWithLayoutSpec
      MultipleActions
      RelativeSpec
    )
  end

  describe 'layout' do
    it "should use :except and :only in layout" do
      class ::LayoutFiltersSpec
        inherit Rad::Controller::Abstract
        layout '/layouts/app', only: :action_with_layout

        def action_with_layout; end
        def action_without_layout; end
      end

      ccall(LayoutFiltersSpec, :action_with_layout, format: 'html').should == "Layout html, content"
      ccall(LayoutFiltersSpec, :action_without_layout).should == "content"
    end

    it "should apply formats to layout" do
      class LayoutSpec
        inherit Rad::Controller::Abstract
        layout '/layouts/app'

        def action; end
      end

      ccall(LayoutSpec, :action, format: 'html').should == "Layout html, content"
      ccall(LayoutSpec, :action, format: 'js').should == "Layout js, content"
    end

    it "should take layout: false or layout: '/another_layout'" do
      class AnotherLayout
        inherit Rad::Controller::Abstract
        layout '/layout/app'

        def action; end

        def without_layout
          render action: :action, layout: false
        end

        def another_layout
          render action: :action, layout: '/layouts/admin'
        end
      end

      ccall(AnotherLayout, :without_layout).should == "action"
      ccall(AnotherLayout, :another_layout).should == "Admin layout, action"
    end


    it "should take into account :layout when rendering template" do
      class ::ExplicitRenderSpec
        inherit Rad::Controller::Abstract
        layout '/layouts/app'

        def with_layout
          render '/some_template'
        end

        def without_layout
          render '/some_template', layout: false
        end
      end

      ccall(ExplicitRenderSpec, :with_layout, format: 'html').should == "Layout html, some template"
      ccall(ExplicitRenderSpec, :without_layout, format: 'html').should == "some template"
    end
  end

  it "should render template inside of controller" do
    class ::RenderInsideOfControllerSpec
      inherit Rad::Controller::Abstract

      def some_action
        render '/some_template'
      end
    end

    ccall(RenderInsideOfControllerSpec, :some_action).should == "some template"
  end

  it "should not allow to render partials as actions" do
    class ::ForbidPartialAsActionSpec
      inherit Rad::Controller::Abstract
      def action; end
    end

    ccall(ForbidPartialAsActionSpec, :action).should == ''
  end

  it "should render view with right format" do
    class FormatSpec
      inherit Rad::Controller::Abstract
      def action; end
    end

    ccall(FormatSpec, :action, format: 'html').should == "html format"
    ccall(FormatSpec, :action, format: 'js').should == "js format"
  end

  it "should be able to use rad.template.render for different purposes (mail for example)" do
    rad.template.render("/standalone", locals: {a: 'a'}).should == 'standalone usage, a'
  end

  it "should not rener if already rendered in controller" do
    class ::AlreadyRenderedSpec
      inherit Rad::Controller::Abstract

      def action
        render '/already_rendered_spec/custom_template'
      end
    end

    ccall(AlreadyRenderedSpec, :action).should == 'custom content'
  end

  it "should handle serialization obj ('xml', 'json')" do
    class ::SpecialFormatSpec
      inherit Rad::Controller::Abstract

      def json_action
        render json: {a: "b"}
      end

      def xml_action
        render xml: {a: "b"}
      end
    end

    ccall(SpecialFormatSpec, :json_action, format: 'json').should == %({"a":"b"})
    -> {
      ccall(SpecialFormatSpec, :json_action, format: 'xml')
    }.should raise_error(/responing with 'json' to the 'xml'/)
  end

  it "should render another action via action: :action_name" do
    class ::AnotherActionSpec
      inherit Rad::Controller::Abstract

      def another_action; end

      def action
        render action: :another_action
      end
    end

    ccall(AnotherActionSpec, :action).should == "another action (action_name: another_action)"
  end

  it "should take :inline option" do
    class ::InlineRenderSpec
      inherit Rad::Controller::Abstract

      def action
        render inline: "content"
      end
    end

    ccall(InlineRenderSpec, :action).should == "content"
  end

  # it ":inline option should render without layout" do
  #   class ::InlineWithLayoutSpec
  #     inherit Rad::Controller::Abstract
  #
  #     layout '/layouts/app'
  #
  #     def action
  #       render inline: "content"
  #     end
  #   end
  #
  #   ccall(InlineWithLayoutSpec, :action).should == "content"
  # end

  it "should render correct action inside of special 'actions.xxx' template file" do
    class ::MultipleActions
      inherit Rad::Controller::Abstract

      def increase; end
      def decrease; end
      def action_without_template; end
    end

    ccall(MultipleActions, :increase).should == "plus\n"
    ccall(MultipleActions, :decrease).should == "minus\n"
    ccall(MultipleActions, :action_without_template).should == ''
  end

  it "relative templates should be searched as: CurrentClass -> SuperClass -> SameDir" do
    module ::RelativeSpec
      class A
        inherit Rad::Controller::Abstract

        def show; end
      end

      class B < A
      end
    end

    ccall(RelativeSpec::B, :show).should == 'form b'
  end
end