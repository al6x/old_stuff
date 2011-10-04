class Domain < ActiveRecord::Base
  establish_connection_to_service_mix
  
  belongs_to :account
end