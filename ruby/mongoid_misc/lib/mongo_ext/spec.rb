rspec do
  def clear_mongo_database name = 'test'
    connection = Mongo::Connection.new
    db = connection.db(name)
    db.collection_names.each do |name|
      next if name =~ /^system\./
      db.collection(name).drop
    end    
    db
  end
end