require File.dirname(__FILE__) + '/../spec_helper'

describe "File Audit" do
  DATA_DIR = "#{File.dirname(__FILE__)}/../data"
  
  def open_small_file &block
    File.open("#{DATA_DIR}/100.txt", &block)
  end
  
  def open_big_file &block
    File.open("#{DATA_DIR}/302.txt", &block)
  end
  
  before :all do
    class ::Amodel
      include MongoMapper::Document
      include Paperclip
      
      interpolation = "/system/:account/:space/:class/:id/:attachment"
      has_attached_file :data, 
        :path => (":rails_root/public" + interpolation),
        :url => (":rails_root/public" + interpolation)
      
      validates_file :data
      trace_file :data      
      
      def disable_file_audit?
        false
      end
    end
  end
  
  after :all do
    Object.send :remove_const, :Amodel if Object.const_defined? :Amodel
  end
  
  before :each do
    set_default_space
    User.current = @user = Factory.create(:user)
  end
  
  it "should check max space files size" do
    Account.current.max_account_files_size = 200
    m = Amodel.new
    
    open_small_file do |f|
      m.data = f
      m.should be_valid
    end
    
    open_big_file do |f|
      m.data = f
      m.should_not be_valid
    end
  end
  
  it "shouldn't count the same file when model updated" do
    # assign file
    m = nil
    open_small_file{|f| m = Amodel.create :data => f}        
    m.data_file_size.should == 100
    m.data_old_file_size.should == 100
    User.current.files_size.should == 100
    Account.current.files_size.should == 100
    
    m.save!    
    m.data_file_size.should == 100
    m.data_old_file_size.should == 100
    User.current.files_size.should == 100
    Account.current.files_size.should == 100
  end
  
  it "should check max user files size" do
    Space.current.max_user_files_size = 200
    m = Amodel.new
    
    open_small_file do |f|
      m.data = f
      m.should be_valid
    end
    
    open_big_file do |f|
      m.data = f
      m.should_not be_valid
    end
  end
  
  it "should check max file size" do
    Account.current.max_file_size = 200
    m = Amodel.new
    
    open_small_file do |f|
      m.data = f
      m.should be_valid
    end
    
    open_big_file do |f|
      m.data = f
      m.should_not be_valid
    end
  end
  
  it "should also decrease files size" do
    # assign file
    m, m2 = nil
    open_small_file{|f| m = Amodel.create :data => f}    
    open_big_file{|f| m2 = Amodel.create :data => f}
    
    User.current.files_size.should == 402
    Account.current.files_size.should == 402
    
    # destroying file
    m2.destroy
    User.current.files_size.should == 100
    Account.current.files_size.should == 100
    User.current.reload; Account.current.reload
    User.current.files_size.should == 100
    Account.current.files_size.should == 100
  end
  
  it "shoud trace file size" do
    # assign file
    m = nil
    open_small_file{|f| m = Amodel.create :data => f}    
    
    m.data_file_size.should == 100
    m.data_old_file_size.should == 100
    User.current.files_size.should == 100
    Account.current.files_size.should == 100
    User.current.reload; Account.current.reload
    User.current.files_size.should == 100
    Account.current.files_size.should == 100    
    
    # update file
    open_big_file{|f| m.data = f; m.save!}
    
    m.data_file_size.should == 302
    m.data_old_file_size.should == 302
    User.current.files_size.should == 302
    Account.current.files_size.should == 302
    User.current.reload; Account.current.reload
    User.current.files_size.should == 302
    Account.current.files_size.should == 302
    
    # assign another file
    m2 = nil
    open_small_file{|f| m2 = Amodel.create :data => f}
    
    m2.data_file_size.should == 100
    m2.data_old_file_size.should == 100
    User.current.files_size.should == 402
    Account.current.files_size.should == 402
    
    # another user
    User.current = Factory.create :user
    m3 = nil
    open_small_file{|f| m3 = Amodel.create :data => f}
    
    User.current.files_size.should == 100
    @user.files_size.should == 402
    Account.current.files_size.should == 502    
  end
  
end