require 'etl'

$tec4y = OpenObject.new

$tec4y.base = ETL::Base.new "tec4y", 
  # :clear => true,
  :base_directory => '/Users/alex/tmp'

require "#{File.dirname __FILE__}/extractor"
require "#{File.dirname __FILE__}/transformer"
require "#{File.dirname __FILE__}/loader"

p "Extractor Running"
$tec4y.extractor.run
$tec4y.extractor.print_info

p "Transformer Running"
$tec4y.transformer.run
$tec4y.transformer.print_info

p "Loader Running"
$tec4y.loader.run
$tec4y.loader.print_info