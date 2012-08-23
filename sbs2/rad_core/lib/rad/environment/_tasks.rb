task :environment do
  require 'rad'
  require 'rad/cli'

  Rad::Cli.new.set_runtime_path!

  rad.mode = ENV['m'] || ENV['mode'] || ENV['env'] || ENV['environment'] || :development

  load './init.rb' if './init.rb'.to_file.exist?
end