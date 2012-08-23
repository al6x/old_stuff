# Handy configuration shortcuts.
class Micon::Core
  def configure dir, &block
    configurator = Rad::Configurator.new dir
    block.call configurator if block
  end
end