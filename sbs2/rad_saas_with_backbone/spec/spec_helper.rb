saas_dir = File.expand_path "#{__FILE__}/../.."
$LOAD_PATH << "#{saas_dir}/server" unless $LOAD_PATH.include? "#{saas_dir}/server"

require 'rad'
require 'rad/spec'

rad.saas

require 'saas/spec'