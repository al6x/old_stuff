require 'spec_helper'

describe "Abstract" do
  with_view_path "#{spec_dir}/views"
  with_abstract_controller

  after :all do
    remove_constants %w(
      WorkspaceVariablesSpec
      SpecialResultSpec
      RespondToSpec
      ViewVariablesSpec
      OperationsOrderSpec
      NoTemplateSpec
    )
  end

  it "should set workspace variables" do
    class ::WorkspaceVariablesSpec
      inherit Rad::Controller::Abstract

      def action; end
    end

    ccall WorkspaceVariablesSpec, :action

    workspace.controller.should be_a(WorkspaceVariablesSpec)
    response.should respond_to("body=")

    expected_result = {
      params: {},

      class: WorkspaceVariablesSpec,
      method_name: :action,
      action_name: :action
    }
    workspace.to_hash(true).subset(expected_result.keys).should == expected_result
  end

  it "should be able to throw :halt in controller or view and that result must be assigned as result" do
    class ::SpecialResultSpec
      inherit Rad::Controller::Abstract
      def action
        throw :halt, 'some content'
      end
    end

    ccall(SpecialResultSpec, :action).should == "some content"
  end

  it "respond_to" do
    class ::RespondToSpec
      inherit Rad::Controller::Abstract

      def action
        respond_to do |format|
          format.html{render inline: 'html'}
          format.json{render json: {a: 'b'}}
        end
      end
    end

    ccall(RespondToSpec, :action, format: 'html').should == 'html'
    ccall(RespondToSpec, :action, format: 'json').should == %({"a":"b"})
    lambda{ccall(RespondToSpec, :action, format: 'js')}.should raise_error(/can't respond to 'js' format/)
  end

  it "controller's instance variables must be available in view, and also other variables" do
    class ::ViewVariablesSpec
      inherit Rad::Controller::Abstract

      def action
        @instance_variable = "iv value"
      end
    end

    ccall(ViewVariablesSpec, :action, param: 'param value', format: 'html').should == %(\
controller: ViewVariablesSpec
controller_name: ViewVariablesSpec

class: ViewVariablesSpec
method_name: action
action: action

instance_variable: iv value

params: param value
format: html)
  end

  it "operations order" do
    class ::OperationsOrderSpec
      inherit Rad::Controller::Abstract

      def self.result
        @result ||= []
      end

      around do |controller, block|
        begin
          OperationsOrderSpec.result << :before
          block.call
        ensure
          OperationsOrderSpec.result << :after
        end
      end

      def action
        OperationsOrderSpec.result << :action
      end
    end

    ccall(OperationsOrderSpec, :action)
    OperationsOrderSpec.result.should == [:before, :action, :template, :after]
  end

  it "should render :nothing" do
    class NoTemplateSpec
      inherit Rad::Controller::Abstract

      def action; end
    end

    ccall(NoTemplateSpec, :action).should == ""
  end
end