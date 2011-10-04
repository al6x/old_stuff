class Account < ActiveRecord::Base
  establish_connection_to_service_mix
  
  has_many :domains
  has_many :spaces
  
  class << self
    def scope_tables tables
      conditions = tables.collect{|table| "#{table}.account_id=#{id}"}
      "(#{conditions.join(' AND ')})"
    end
  end
end