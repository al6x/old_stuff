require "spec_helper"

describe "Helpers" do
  set_controller Rad::Face::Demo::Commons
  
  def body
    wcall(:forms)
    response.body
  end
  
  if String.method_defined? :xhtml
    it "form_tag should correctly render form (from error)" do
      body.to_xhtml('#basic_form_tag').to_fuzzy_hash.should == {id: 'basic_form_tag', action: '/some_action', method: 'post'}
    end
  
    it "form_for should correctly render form (from error)" do
      body.to_xhtml('#basic_form_for').to_fuzzy_hash.should == {id: 'basic_form_for', action: '/some_action', method: 'post'}
    end  
  end
end