warn 'code highlighter disabled'
# require 'text_utils/spec_helper'
#
# describe "Markdown" do
#   include RSpec::TextUtilsHelper
#
#   before do
#     @processor = TextUtils::CodeHighlighter.new
#     @options = {format: :html}
#   end
#
#   it_should_behave_like 'text processor'
#
#   it "should highlight code" do
#     process(%{<p> text </p><code lang='ruby'>class A; p "Hello World" end</code><p> text </p>}).should =~ /span/i
#     process(%{<p> text </p><code language='ruby'>class A; p "Hello World" end</code><p> text </p>}).should =~ /span/i
#     process(%{<code lang='ruby'>\nclass A \n  def p\n    10\n  end\nend \n</code>}).should =~ /span/i
#   end
#
#   it "should works with < and > in code" do
#     process(%{<code lang='ruby'>class A < ClassB; end</code>}).should include('ClassB')
#   end
#
#   it 'should preserve custom classes in <code>' do
#     process(%{<code lang='ruby' class='my_code'>\nclass A \n  def p\n    10\n  end\nend \n</code>}).should =~ /my_code/i
#   end
#
#   it 'should use ``` code block syntax' do
#     markdown = <<MARKDOWN
# text
#
# ``` ruby
# print "Hello World"
# ```
# MARKDOWN
#
#     process(markdown).should =~ /span/i
#   end
# end