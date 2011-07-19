p 'move to kit'

require 'spec_helper'

describe "Items" do
  with_controllers
  
  before do        
    @user = Factory.create :manager, name: "auser"
    login_as @user
  end
  
  describe "Basic" do
    set_controller Controllers::Items

    it 'should update order' do
      @page = Factory.create :page
      @note1, @note2 = Factory.create(:note, name: 'note1'), Factory.create(:note, name: 'note2')
      @page.items << @note1
      @page.items << @note2
      @page.save!
      @note1.save
      @note2.save
    
      call :container_order, id: @page.to_param, item_id: @note1.to_param, index: 1, format: 'js'
      response.should be_ok
    
      @page.reload
      @page.ordered_items.should == [@note2, @note1]
    end
    
    it 'should update order' do
      @page = Factory.create :page
      @note1, @note2 = Factory.create(:note, name: 'note1'), Factory.create(:note, name: 'note2')
      @page.items << @note1
      @page.items << @note2
      @page.save!
      @note1.save
      @note2.save
    
      call :container_order, id: @page.to_param, item_id: @note1.to_param, index: 1, format: 'js'
      response.should be_ok
    
      @page.reload
      @page.ordered_items.should == [@note2, @note1]
    end
    
  end

  describe "Embedded Mode" do
    set_controller Controllers::Pages
  
    it "embedded item should be deleted if it's container deled" do
      @note = Factory.create :note
      @note.dependent!
      @note.save!
      @page = Factory.create :page
      @page.items << @note
      @page.save!
    
      Note.count.should == 1
    
      call :destroy, id: @page.to_param, format: 'js'
      response.should be_ok
  
      Page.count.should == 0
      Note.count.should == 0
    end
  end
  
  describe "Embedded Mode" do
    set_controller Controllers::Notes
    
    before do 
      @page = Factory.create :page
    end
  
    it "embedded item should be added to it's container (and should be dependent)" do
      call :create, format: 'js', note: {text: 'some text'}, container_id: @page.to_param
      response.should be_ok
          
      Note.count.should == 1
      note = Note.first
      note.text.should =~ /some text/
      note.should be_dependent
      
      @page.reload
      @page.items.size.should == 1
      @page.items.first.text.should =~ /some text/
    end
  end
end