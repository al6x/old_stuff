class UserRole < ActiveRecord::Base
  establish_connection_to_service_mix
  
  acts_as_multitenant :space # TODO1 refactor with default scope
  warn 'refactor it!'
  
  belongs_to :user
  belongs_to :role
end