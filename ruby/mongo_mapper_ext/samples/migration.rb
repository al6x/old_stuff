dir = File.expand_path "#{__FILE__}/../.."
$LOAD_PATH << "#{dir}/lib" unless $LOAD_PATH.include? "#{dir}/lib"

require 'mongo_mapper_ext/mongo_mapper'

#
# database config, a little more complicated because I'm using it with 
# multitenant application and need to manage multiple databases.
#
MongoMapper.db_config = {
  'default' => {'name' => "default_test"},
}
MongoMapper.database = MongoMapper.databases[:default].name

# clearing database DON'T DO IT IN PRODUCTIONS, FOR TESTS ONLY
db = MongoMapper.databases[:default]    
db.collection_names.each do |name|
  next if name =~ /^system\./
  db.collection(name).drop
end

# our model
class User
  include MongoMapper::Document

  key :name, String
end

# defining migration N 1
MongoMapper::Migration.define :default, 1 do |m|
  m.up do |db|
    # db - low-level db from mongo driver, but in this sample we don't need it. 
    # Just keep in mind that You can alter database directly with low-level driver, without MongoMapper.
    
    User.create! name: 'Liliana'
  end
  m.down do |db|
    # you can also downgrade 
  end
end

# database is empty now
p User.count                    # => 0

# migrationg to version 1
MongoMapper::Migration.update :default, 1

p User.count                    # => 1
p User.first.name               # => Liliana

# defining migration N 2
MongoMapper::Migration.define :default, 2 do |m|
  m.up do
    user = User.find_by_name 'Liliana'
    user.name = 'Niccy'
    user.save!
  end
  m.down{}
end

# migrationg to version 2
MongoMapper::Migration.update :default, 2

p User.first.name               # => Niccy

# for rake integration, see mongo_mapper_ext/tasks.rb

# Output
# 
#   0
#   Migration for 'default' Database:
#   Database 'default' upgraded to version 1.
#   1
#   "Liliana"
#   Migration for 'default' Database:
#   Database 'default' upgraded to version 2.
#   "Niccy"