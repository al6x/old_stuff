require 'rspec_ext'

require 'rad' # TODO1 move it to rad/spec

require 'rad/spec'

require 'mongoid_misc' # TODO1 move it to mongoid_misc/spec
require 'mongoid_misc/spec' 

require 'factories'

rspec do
  alias_method :call, :wcall
  alias_method :pcall, :post_wcall
  
  def self.with_models    
    with_mongoid
  end
  
  def self.with_controllers
    with_models
  end
end



rad.blog