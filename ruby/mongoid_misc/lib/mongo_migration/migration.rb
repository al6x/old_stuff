class Mongo::Migration
  attr_accessor :adapter
  
  def initialize adapter = nil
    @adapter = adapter
  end
  
  def define version, database_name = :default, &block    
    raise "version should be an Integer! (but you provided '#{version}' instad)!" unless version.is_a? Integer
    definition = Definition.new
    block.call definition
    definitions[database_name][version] = definition
  end
          
  def update version, database_name = :default
    db = adapter.database database_name
    
    if metadata(db)['version'] == version
      adapter.logger.info "Database '#{database_name}' already is of #{version} version, no migration needed"
      return false
    else
      adapter.logger.info "Migration for '#{database_name}', updating to #{version}"
    end
    
    increase_db_version database_name, db while metadata(db)['version'] < version
    decrease_db_version database_name, db while metadata(db)['version'] > version
    true
  end
      
  def metadata db
    col = db.collection 'db_metadata'
    col.find_one || {'version' => 0}
  end
  
  def definitions
    @definitions ||= Hash.new{|h, k| h[k] = []} 
  end
    
  protected
    def increase_db_version database_name, db    
      m = metadata(db)
      migration = definitions[database_name][m['version'] + 1]        
      raise "No upgrade for version #{m['version'] + 1} of '#{database_name}' Database!" unless migration and migration.up
      
      migration.up.call db
      
      m['version'] += 1        
      update_metadata db, m
      
      adapter.logger.info "Database '#{database_name}' upgraded to version #{m['version']}."
    end
    
    def decrease_db_version database_name, db
      m = metadata(db)
      migration = definitions[database_name][m['version']]        
      raise "No downgrade for version #{m['version']} of '#{database_name}' Database!" unless migration and migration.down
      
      migration.down.call db
      
      m['version'] -= 1
      update_metadata db, m
      
      adapter.logger.info "Database '#{database_name}' downgraded to version #{m['version']}."
    end

    
    def update_metadata db, metadata
      col = db.collection 'db_metadata'
      col.save metadata.to_hash
    end
end