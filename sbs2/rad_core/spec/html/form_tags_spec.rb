require 'html/spec_helper'

describe "FormTags" do
  before do
    @t = TestTemplateContext.new
  end

  it "check_box_tag" do
    @t.check_box_tag('item').should == %(<input class=" checkbox_input" name="item" type="checkbox" value="1"></input>)
  end

  it "field_set_tag" do
    @t.field_set_tag{'content'}.should == %(<fieldset class=" fieldset_input">content</fieldset>)
  end

  it "file_field_tag" do
    @t.file_field_tag('item').should == %(<input class=" file_input" name="item" type="file"></input>)
  end

  if String.method_defined? :to_xhtml
    it "form_tag" do
      @t.form_tag(id: 'the_form', action: '/'){"content"}
      @t.buffer.to_xhtml('#the_form').to_fuzzy_hash.should == {id: 'the_form', action: '/', content: 'content', method: 'post'}
    end
  else
    warn "WARN: skipping spec"
  end

  it "hidden_field_tag" do
    @t.hidden_field_tag('item', 'hidden value').should == %(<input class=" hidden_input" name="item" type="hidden" value="hidden value"></input>)
  end

  it "password_field_tag" do
    @t.password_field_tag('item').should == %(<input class=" password_input" name="item" type="password"></input>)
  end

  it "radio_button_tag" do
    @t.radio_button_tag('item').should == %(<input class=" radio_input" name="item" type="radio" value="1"></input>)
  end

  it "select_tag" do
    @t.select_tag('item', nil, [["Dollar", "$"], ["Kroner", "DKK"]]).should ==
      %(<select class=" select_input" name="item">\n<option value="$">Dollar</option>\n<option value="DKK">Kroner</option>\n</select>)

    @t.select_tag('item', '$', [["Dollar", "$"], ["Kroner", "DKK"]], class: 'highlight').should ==
      %(<select class="highlight select_input" name="item">\n<option selected="selected" value="$">Dollar</option>\n\
<option value="DKK">Kroner</option>\n</select>)
  end

  it "submit_tag" do
    @t.submit_tag('ok').should == %(<input class=" submit_input" type="submit" value="ok"></input>)
  end

  it "text_field_tag" do
    @t.text_field_tag('item', 'value').should == %(<input class=" text_input" name="item" type="text" value="value"></input>)
  end

  it "text_area_tag" do
    @t.text_area_tag('item', 'value').should == %(<textarea class=" textarea_input" name="item">value</textarea>)
  end
end