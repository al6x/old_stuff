require 'spec_helper'

describe "Selectors" do
  with_controllers
  set_controller Controllers::Selectors
  login_as :manager

  it_should_behave_like "Items Controller CRUD"

  describe "Querying" do
    before do
      @selector = Factory.create :selector, query: ['post']

      @post = Factory.create :note, name: 'Post Name', tags: ['post']
      @note = Factory.create :note, name: 'Note Name'
    end

    it "set query" do
      pcall :create, model: {name: 'selector', query_as_string: "post, news"}, format: 'js'
      response.should be_redirect

      Models::Selector.by_name('selector').query.should == ['news', 'post']
    end

    it "display only selected items" do
      call :show, id: @selector.to_param
      response.should be_ok

      response.body.include?(@post.name).should be_true
      response.body.include?(@note.name).should be_false
    end

    it "pagination" do
      call :show, id: @selector.to_param, page: 1
      response.should be_ok
    end

    it "shouldn't show non-existing selector" do
      call :show, id: 'non_existing_id'
      response.should be_not_found
    end
  end
end