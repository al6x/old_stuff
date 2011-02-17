$APP_DIR = File.expand_path(File.dirname(__FILE__))

require "#{$APP_DIR}/config/init"

Crystal::Config::DEFAULTS['environment'] = $CENV || 'production'
Micon[:environment]

Crystal.build_common_app self
run Crystal