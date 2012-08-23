require 'mongo_ext/spec_helper'

describe "Miscellaneous" do
  before do
    db = clear_mongo_database
    @collection = db.collection 'test'
  end
  
  it "upsert should update" do
    id = @collection.save count: 2
    @collection.upsert!({_id: id}, :$inc => {count: 1})
    @collection.find(_id: id).first['count'].should == 3
  end

  it "upsert should set" do
    id = @collection.save({})
    @collection.upsert!({_id: id}, :$inc => {count: 1})
    @collection.find(_id: id).first['count'].should == 1
  end
end