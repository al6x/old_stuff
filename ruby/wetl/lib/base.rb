class ETL::Base
  attr_accessor :connection, :project, :db_name, :db, :base_directory, :options
  
  # attr_accessor :links, :pages, :domain, :options, :db_name, :directory, :objects, :skipped_pages, :loaded_objects
  
  def initialize project = "", opt = {}    
    self.project = project.should_not! :be_nil    
    self.options = opt.to_openobject    
    
    # DB
    self.db_name = project
    self.connection = Mongo::Connection.new # nil, nil, :logger => Logger.new(STDOUT)
    self.connection.drop_database db_name if options.clear?    
    self.db = connection.db db_name
    
    # File Storage
    options.base_directory.should_not_be! :blank
    self.base_directory = "#{options.base_directory}/#{project}"
    FileUtils.rm_rf base_directory if options.clear?
    FileUtils.mkdir_p base_directory unless File.exist? base_directory
  end
end