require 'mongo_migration/spec_helper'

describe "Migration" do
  before :all do
    class TestAdapter
      def initialize
        @logger = Logger.new(nil)
        
        connection = Mongo::Connection.new
        @databases = {
          default: connection.db('test'),
          global:  connection.db('global_test')
        }
      end
      
      attr_reader :logger
      def database name; @databases[name] end
    end
    Mongo::Migration::Mongoid = TestAdapter
  end
  after(:all){remove_constants :TestAdapter, :MyAdapter}
  
  before do    
    clear_mongo_database    
    
    @adapter = TestAdapter.new
    @migration = Mongo::Migration.new @adapter
  end
  
  it "basic sample" do    
    # use existing adapter or define Your own, it has only 2 methods 
    # and about 10 lines of code (use Mongoid as a sample)
    adapter = Mongo::Migration::Mongoid.new
    
    # initialize migration
    Mongo.migration = Mongo::Migration.new adapter
    
    # configure migration by defining migration steps 
    # You can place all of them in one file or as different
    # files in one directory
    Mongo.migration.define 1 do |m|
      m.up do |db|
        # update Your models
        # User.create name: 'Bob'
        
        # or use db directly
        db.collection('users').insert({name: 'Bob'})
      end
      m.down{|db| db.collection('users').remove({name: 'Bob'})}
    end
        
    Mongo.migration.define 2 do |m|
      m.up{|db| db.collection('users').insert({name: 'John'})}
      m.down{|db| db.collection('users').remove({name: 'John'})}
    end
    
    # specify what version (it can be any version) do You need
    # and apply migration
    # You can call it directly or via Rake task
    Mongo.migration.update 2    
    adapter.database(:default).collection('users').find.count.should == 2
    
    # rollback to any version changes
    Mongo.migration.update 0
    adapter.database(:default).collection('users').find.count.should == 0
  end
  
  it "Shouldn't update if versions are the same" do
    @migration.update(0).should be_false
  end
  
  it "migration should provide access to database" do 
    @migration.define 1 do |m|
      m.up do |db|
        db.collection('users').insert({name: 'Bob'})
      end
    end  
    @migration.update(1).should be_true
    @adapter.database(:default).collection('users').find.count.should == 1
  end    
  
  it "increase_db_version" do
    check = mock
    @migration.define 1 do |m|
      m.up{check.up}
    end
  
    check.should_receive :up
    @migration.update(1).should be_true    
    @migration.metadata(@adapter.database(:default))['version'].should == 1
  end
  
  it "decrease_db_version" do
    check = mock
    @migration.define 1 do |m|
      m.up{check.up}
      m.down{check.down}
    end
    check.should_receive :up
    @migration.update(1).should be_true

    check.should_receive :down
    @migration.update(0).should be_true
    @migration.metadata(@adapter.database(:default))['version'].should == 0
  end
  
  describe "multiple databases" do
    before{clear_mongo_database 'global_test'}        
  end
end