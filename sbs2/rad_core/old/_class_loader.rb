require 'class_loader'

# Watching and reloading files only in production.
rad.after :environment do
  ClassLoader.stop_watching! unless rad.development?
end

lib_path = File.expand_path "#{__FILE__}/../../.."
autoload_path lib_path, false