require 'rake_ext'
require 'ruby_ext'

task :environment do
  require 'rad'
  rad.mode = ENV['m'] || ENV['mode'] || ENV['env'] || ENV['environment'] || :development
  
  require 'rad_ext/utils/cli_helper'
  Rad::CliHelper.use_runtime_path!
  
  rad.runtime_path = File.expand_path '.'

  load "./init.rb"
  rad.environment
end