require "spec_helper"

describe "HamlBuilder use cases" do
  def build_hoo h
    Rad::Face::HtmlOpenObject.initialize_from h
  end
  
  it "should threat newlines as blank" do
    o = build_hoo(blank_line: "\n\n  \t", line_with_content: "abc")
    o.blank_line?.should be_false
    o.line_with_content?.should be_true
  end
end