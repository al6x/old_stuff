class Mongo::Migration::Mongoid
  def logger
    Mongoid.logger
  end    
  
  def database name
    name == :default ? Mongoid.master : Mongoid.databases[name.to_s]
  end
end