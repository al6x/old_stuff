ActiveRecord::Base.class_eval do
  def self.establish_connection_to_service_mix
    establish_connection "service_mix_#{RAILS_ENV}"
  end
end