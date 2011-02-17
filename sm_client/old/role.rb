class Role < ActiveRecord::Base
  establish_connection_to_service_mix
  
  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles
end