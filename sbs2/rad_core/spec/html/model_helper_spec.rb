require 'html/spec_helper'

describe "ModelHelper" do
  before do
    @t = TestTemplateContext.new
  end

  it "form_for" do
    @t.form_for(:aname, nil, id: 'the_form', action: '/'){"content"}
    @t.buffer.to_xhtml('#the_form').to_fuzzy_hash.should == {id: 'the_form', action: '/', content: 'content', method: 'post'}
  end

  it "error_messages" do
    @t.form_for(:aname, nil){|f| f.error_messages}
    lambda{@t.buffer.to_xhtml('form div')}.should raise_error(/not found/)

    model = {errors: {base: ['some error']}}
    @t.buffer = ""
    @t.form_for(:book, model){|f| f.error_messages}
    @t.buffer.to_xhtml('form div').to_fuzzy_hash.should == {class: 'error_messages', content: 'some error'}
  end

  it "field error" do
    model = {
      title: "Super Hero",
      errors: {title: ['some error in title']}
    }
    @t.form_for(:book, model){|f| f.text_field(:title)}
    doc = @t.buffer.to_xhtml
    doc.css("form div.field_error_messages").first.content.should == "some error in title"
    doc.css("form span.field_with_errors input").first.to_fuzzy_hash.should == {name: "book[title]", value: "Super Hero"}
  end

  it "should insert human readable label if not specified" do
    model = {}
    model.stub(:t).and_return{|k| "translated #{k}"}

    @t.form_for(:book, model){|f| f.text_field(:title)}
    @t.buffer.should =~ /translated title/

    @t.form_for(:book, model){|f| f.text_field(:title, label: 'some label')}
    @t.buffer.should =~ /some label/
  end

  it "field_helpers" do
    model = {
      available: false,
      title: "Super Hero",
      theme: 'simple'
    }

    @t.form_for(:book, model){|f| %{
      #{f.check_box :available}
      #{f.file_field :title}
      #{f.hidden_field :title}
      #{f.password_field :title}
      #{f.radio_button :available}
      #{f.submit 'Ok'}
      #{f.text_field :title}
      #{f.text_area :title}
      #{f.select :theme, %w(a b)}
    } }
    doc = @t.buffer.to_xhtml

    # checkbox is special case, we are using it with <input type='hidden' .../> tag.
    doc.css("*[type='hidden']").first.to_fuzzy_hash.should == {name: "book[available]", value: '0'}
    doc.css("*[type='checkbox']").first.to_fuzzy_hash.should == {name: "book[available]", value: '1'}

    doc.css("*[type='file']").first.to_fuzzy_hash.should == {name: "book[title]"}
    doc.css("*[type='hidden']").last.to_fuzzy_hash.should == {name: "book[title]", value: 'Super Hero'}
    doc.css("*[type='password']").first.to_fuzzy_hash.should == {name: "book[title]"}
    doc.css("*[type='radio']").first.to_fuzzy_hash.should == {name: "book[available]", value: '1'}
    doc.css("*[type='submit']").first.to_fuzzy_hash.should == {value: 'Ok'}
    doc.css("*[type='text']").first.to_fuzzy_hash.should == {name: "book[title]", value: 'Super Hero'}
    doc.css("textarea").first.to_fuzzy_hash.should == {name: "book[title]", content: 'Super Hero'}
    doc.css("select").first.to_fuzzy_hash.should == {name: "book[theme]"}
  end
end