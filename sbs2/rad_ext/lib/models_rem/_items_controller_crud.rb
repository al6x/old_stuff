shared_examples_for "Items Controller CRUD" do
  before do
    @controller_class.should be_present
    @model_class ||= @controller_class.model_class
    @model_name ||= @model_class.alias.underscore
  end

  %w(html json).each do |format|
    it "show :#{format}" do
      @item = factory.create @model_name
      call :show, id: @item.to_param, format: format
      response.should be_ok
      response.body.should include(@item.name)
    end

    it "all :#{format}" do
      @item = factory.create @model_name
      call :all, format: format
      response.should be_ok
      response.body.should include(@item.name)
    end
  end

  it "edit :js" do
    item = factory.create @model_name
    call :edit, id: item.to_param, format: 'js'
    response.should be_ok
  end

  %w(js json).each do |format|
    it "new :#{format}" do
      call :new, format: format
      response.should be_ok
    end

    it "create :#{format}" do
      item_attributes = factory.attributes_for @model_name
      pcall :create, model: item_attributes, format: format

      (format == 'js') ? response.body.should(include('window.location')) : response.should(be_ok)
      @model_class.count.should == 1
      item = @model_class.first
      item.name.should == item_attributes[:name]
    end

    it "update :#{format}" do
      item = factory.create @model_name
      pcall :update, id: item.to_param, model: {name: 'new_name'}, format: format

      response.should be_ok
      response.body.should =~ /new_name|reload/ if format == 'js'

      item.reload
      item.name.should == 'new_name'
    end

    it "delete :#{format}" do
      item = factory.create @model_name
      pcall :delete, id: item.to_param, format: format
      response.should be_ok
      @model_class.count.should == 0
    end
  end
end