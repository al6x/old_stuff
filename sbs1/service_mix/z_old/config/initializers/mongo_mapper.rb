require 'mongo_mapper_ext'

MongoMapper.db_config.should! :include, 'accounts'
MongoMapper.connection = MongoMapper.connections['accounts']
MongoMapper.database = MongoMapper.db_config['accounts']['name']