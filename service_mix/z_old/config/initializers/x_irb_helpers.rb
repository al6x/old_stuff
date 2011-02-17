if "irb" == $0
  # ActiveRecord::Base.logger = Logger.new(STDOUT)
  
  Account.current = Account.find_by_name('development').should_not! :be_nil
  Space.current = Account.current.spaces.find_by_name('default').should_not! :be_nil
  
  MongoMapper.db_config.should! :include, 'accounts'
  MongoMapper.connection = MongoMapper.connections['accounts']
  MongoMapper.database = MongoMapper.db_config['accounts']['name']

  User.current = User.find_by_name('admin')
end