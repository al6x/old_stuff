require 'mongoid_misc'

class Rad::Models
  attr_accessor :config
end

rad.register :models do  
  Rad::Models.new
end

# we use here :after because we need models.config and it will be availiable 
# only after component has been created
rad.after :models do    
  Mongoid.configure do |config|
    config.logger = rad.logger
  end
  
  # Support for Heroku deployment, it doesn't allow configuration files, 
  # it only allows to use environment variables.
  # Sample: mongoid_host=staff.mongohq.com mongoid_port=10065 mongoid_database=rad_sample mongoid_username=rad_sample mongoid_password=
  %w(host port database username password).each do |key|
    if value = ENV["mongoid_#{key}"]
      value = value.to_i if key == 'port'
      (rad.models.config ||= {})[key] = value
    end
  end
puts rad.models.config.inspect
  Mongoid.from_hash rad.models.config if rad.models.config
end