require 'mongo_ext/spec'

# 
# disabling :set_database, all tests will use the same :test database.
# 
Mongoid::MultiDatabase::ClassMethods.class_eval do
  alias_method :_set_database, :set_database
  def set_database database_name; end
end


# #        
# # disabpling :set_database_alias
# # 
# Mongoid::Miscellaneous::ClassMethods.class_eval do
#   alias_method :_set_database_alias, :set_database_alias
#   def set_database_alias alias_name; end
# end


# 
# Configuring Mongoid to use :test database and clearing database before each test
# 
rspec do
  def self.with_mongoid
    before :all do
      Mongoid.configure do |config|
        connection = Mongo::Connection.new
        config.master = connection.db('test')
      end
    end
    
    before do
      clear_mongo_database
    end
  end
end