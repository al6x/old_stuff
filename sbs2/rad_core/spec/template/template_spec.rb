require 'spec_helper'

describe "Template" do
  with_view_path "#{spec_dir}/templates"

  old_mode = nil
  before do
    old_mode = rad.mode
    rad.mode = :development, true
  end
  after do
    rad.mode = old_mode, true
    remove_constants :Tmp
  end

  inject :template

  def render *a, &b
    template.render *a, &b
  end

  describe 'special' do
    it "read" do
      template.read('/other/template').should == %{<% "ruby code" %> content}
    end

    it "exist?" do
      template.should exist('/other/template')
      template.should_not exist('/other/non-existing-template')
    end

    it "template prefixes" do
      template.exist?('/prefixes/underscored', prefixes: ['']).should be_false
      render('/prefixes/underscored', prefixes: ['_', '']).should == "underscored"
      render('/prefixes/underscored.erb', prefixes: ['_', '']).should == "underscored"

      template.exist?('/prefixes/without_prefix', prefixes: ['_']).should be_false
      render('/prefixes/without_prefix', prefixes: ['']).should == "whthout prefix"
    end

    it "should not use prefixes for :action" do
      template.exist?('/prefixes/underscored').should be_true
      template.exist?('/prefixes/underscored', prefixes: [''], exact_format: true).should be_false
    end
  end

  describe 'basic' do
    it "general" do
      class Tmp
        attr_accessor :value

        def initialize ivariable, value
          @ivariable = ivariable
          @value = value
        end
      end

      obj = Tmp.new 'instance variable value', 'object value'
      options = {
        instance_variables: [obj, {ivariable2: "instance variable value 2"}],
        object: obj,
        locals: {lvariable: 'local value'},
        format: 'html'
      }

      result = render("/basic/general", options){|content_name| "content for :#{content_name}"}

      check = %{\
Instance variable: instance variable value
Instance variable 2: instance variable value 2
Object value: object value
Locals value: local value
Yield: content for :content}

      result.should == check
    end

    it "should not render wrong format if :action specified" do
      template.exist?('/basic/non_existing_format', format: 'html', prefixes: [''], exact_format: true).should be_true
      template.exist?('/basic/non_existing_format', format: :invalid, prefixes: [''], exact_format: true).should be_false

      # from error
      template.exist?('non_existing_format', format: :invalid, prefixes: [''], exact_format: true, current_dir: "#{spec_dir}/views/basic").should be_false
    end

    it "extension" do
      render('/basic/extension').should == "some content"
      render('/basic/extension.erb').should == "some content"
    end

    it "must support custom context_class" do
      class Tmp < Rad::Template::Context
        def custom_helper
          'custom helper'
        end
      end

      render('/basic/custom_context', context: Tmp.new).should == "content from custom helper"
    end

    it "no template" do
      lambda{render('/non-existing-template')}.should raise_error(/no template/)
    end

    it "should render arbitrary file" do
      render(file: "#{spec_dir}/file.erb").should == "file template"
    end
  end

  describe 'format' do
    it "basic" do
      render('/format/format', format: 'html', prefixes: [''], exact_format: true).should == "html format"
      render('/format/format', format: 'js', prefixes: [''], exact_format: true).should == "js format"
      render('/format/format', format: :non_existing, prefixes: [''], exact_format: true).should == "universal format"
      render('/format/format.html', format: 'js', prefixes: [''], exact_format: true).should == "html format"
      render('/format/format.html.erb', format: 'js', prefixes: [''], exact_format: true).should == "html format"
    end

    it "nesting different formats" do
      render('/nesting_format/dialog', format: 'js', prefixes: [''], exact_format: true).should == %(rad.dialog().show("dialog, dialog form"))
    end

    it "should not force format for partials (if :action not specified)" do
      render('/format_for_partials/dialog', format: 'js', prefixes: [''], exact_format: true).should == %(rad.dialog().show("dialog form"))
    end
  end

  describe 'nested' do
    it "should render relative templates" do
      render('/nested/relative/a').should == "template a, template b"
      lambda{render('b')}.should raise_error(/You can't use relative template path/)
      current_dir = "#{spec_dir}/templates/nested/relative"
      render('b', current_dir: current_dir).should == "template b"
    end

    it "should render relative templates with complex path (../../xxx)" do
      render('/nested/relative/c').should == "template c, shared template"
    end

    it "nested templates should use the same format" do
      render('/nested/format/a', format: 'js').should == "b.js"
    end
  end

  describe "layout" do
    def render_with_layout path, options, layout
      content, context = template.basic_render(template.parse_arguments(path, options))

      render layout, context: context do |*args|
        if args.empty?
          content
        else
          args.size.must.be == 1
          variable_name = args.first.to_s
          context.content_variables[variable_name]
        end
      end
    end

    it "templates and layout must share the same context" do
      render_with_layout(
        '/layout/same_context/a', {instance_variables: {ivariable: "ivariable"}},
        '/layout/same_context/layout'
      ).should == "layout ivariable content a ivariable content b ivariable"
    end

    it "content_for" do
      render_with_layout(
        '/layout/content_for/content', {},
        '/layout/content_for/layout'
      ).should == %{\
head
content
bottom}
    end

    it "basic" do
      render_with_layout(
        '/layout/basic/content', {},
        '/layout/basic/layout'
      ).should == "layotu begin content end"
    end

    it "layout with format" do
      render_with_layout(
        '/layout/format/content', {format: 'html'},
        '/layout/format/layout'
      ).should == "html layout begin html content end"

      render_with_layout(
        '/layout/format/content', {format: 'js'},
        '/layout/format/layout'
      ).should == "js layout begin js content end"
    end

    it "layout should support yield in partials (from error)" do
      render_with_layout(
        '/layout/nested_yield/a', {},
        '/layout/nested_yield/layout'
      ).should == "some content"
    end
  end

end