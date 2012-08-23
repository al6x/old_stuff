require 'spec_helper'

describe "Error handling" do
  with_view_path "#{spec_dir}/views"

  isolate :conveyors

  before do
    rad.controller.stub!(:test_error_template).and_return(rad.controller.development_error_template)

    rad.conveyors.web do |web|
      web.use Rad::Controller::Processors::ControllerErrorHandling
      web.use Rad::Controller::Processors::ControllerCaller
    end
  end

  before :all do
    rad.controller
  end
  after :all do
    remove_constants %w(
      DisplayErrorWithFormat
      DiferrentErrorHandlingSpec
      ErrorInRedirectSpec
    )
  end

  it "should correctly display error messages in :development (with correct format)" do
    class ::DisplayErrorWithFormat
      inherit Rad::Controller::Abstract

      def method
        raise params.error
      end
    end

    rad.mode = :development, true

    error = StandardError.new('some error')

    ccall(
      DisplayErrorWithFormat, :method,
      {error: error, format: 'html'}
    ).should =~ /html.+some error/m

    ccall(
      DisplayErrorWithFormat, :method,
      {error: error, format: 'js'}
    ).should =~ /some error/

    ccall(
      DisplayErrorWithFormat, :method,
      {error: error, format: :non_existing_mime}
    ).should =~ /some error/
  end

  it "should catch errors with redirect (from error)" do
    # error: if response.headers['Location'] has been set before redirect, it'll do redirect
    # after error will be catched and no error message will be displayed

    class ::ErrorInRedirectSpec
      inherit Rad::Controller::Abstract

      def a
        response.headers['Location'] = '/'
        raise 'some error'
      end
    end

    rad.mode = :development, true

    ccall(ErrorInRedirectSpec, :a, format: 'html')
    response.headers['Location'].should be_nil
  end

  describe "should be different in :test, :development and :production" do
    before :all do
      class ::DiferrentErrorHandlingSpec
        inherit Rad::Controller::Abstract

        def a; end
        def b
          raise 'some error'
        end
        def c; end
      end
    end

    it "in :production errors shouldn't be shown to user"

    it "in development errors should be catched" do
      rad.mode = :development, true

      # with view
      ccall(DiferrentErrorHandlingSpec, :a).should == 'a'
      %w(html js).each do |format|
        ccall(DiferrentErrorHandlingSpec, :b, format: format).should =~ /some error/
        ccall(DiferrentErrorHandlingSpec, :c, format: format).should =~ /error in template/
      end
    end

    it "should not catch errors in :test environment" do
      rad.mode = :test, true

      # with render
      ccall(DiferrentErrorHandlingSpec, :a).should == 'a'
      lambda{ccall(DiferrentErrorHandlingSpec, :b)}.should raise_error(/some error/)
      lambda{ccall(DiferrentErrorHandlingSpec, :c)}.should raise_error(/error in template/)
    end
  end
end