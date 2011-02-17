Spec::Runner.configure do |config|
  config.before(:each) do    
    MongoMapper.db_config.each do |db_alias, opt|
      db = MongoMapper.databases[db_alias]
      db.collection_names.each do |name|
        db.collection(name).drop
      end
    end
  end
end