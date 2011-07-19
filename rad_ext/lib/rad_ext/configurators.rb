# %w(
#   abstract
#   runtime
#   web
# ).each{|f| require "rad_ext/configurators/#{f}"}

class Micon::Core
  def configure configurator_name, dir, &block      
    configurator_class = "Rad::Configurators::#{configurator_name.to_s.classify}".constantize      
    configurator = configurator_class.new dir
    block.call configurator if block
  end
end