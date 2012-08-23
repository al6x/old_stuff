#
# Some features of ActiveSupport conflicting with Rad, skipping it
#
%w(
  active_support/dependencies.rb
).each do |relative_path|
  $LOAD_PATH.each do |base_path|
    absolute_path = "#{base_path}/#{relative_path}"
    $LOADED_FEATURES << absolute_path if File.exist? absolute_path
  end
end

require 'active_support/all'

# gem 'activesupport' #, '= 2.3.5'
#
# # autoload :BacktraceCleaner, 'active_support/backtrace_cleaner'
# autoload :Base64, 'active_support/base64'
# # autoload :BasicObject, 'active_support/basic_object' we use our own implementation
#
# # autoload :BufferedLogger, 'active_support/buffered_logger'
# # autoload :Cache, 'active_support/cache'
# # autoload :Callbacks, 'active_support/callbacks'
# # autoload :Deprecation, 'active_support/deprecation'
# # autoload :Duration, 'active_support/duration'
# # autoload :Gzip, 'active_support/gzip'
# autoload :Inflector, 'active_support/inflector'
# # autoload :Memoizable, 'active_support/memoizable'
# # autoload :MessageEncryptor, 'active_support/message_encryptor'
# # autoload :MessageVerifier, 'active_support/message_verifier'
# # autoload :Multibyte, 'active_support/multibyte'
# # autoload :OptionMerger, 'active_support/option_merger'
# # autoload :OrderedHash, 'active_support/ordered_hash'
# # autoload :OrderedOptions, 'active_support/ordered_options'
# # autoload :Rescuable, 'active_support/rescuable'
# # autoload :SecureRandom, 'active_support/secure_random'
# # autoload :StringInquirer, 'active_support/string_inquirer'
# autoload :TimeWithZone, 'active_support/time_with_zone'
# autoload :TimeZone, 'active_support/values/time_zone'
# # autoload :XmlMini, 'active_support/xml_mini'
#
# # require 'active_support/vendor'
# require 'active_support/core_ext'
# # require 'active_support/dependencies'
# # require 'active_support/json'


#
# Hacks
#
%w(
  miscellaneous
  time
).each{|f| require "rad/_support/active_support/#{f}"}
require 'yaml_fix'

#
# Locales
#
support_dir = File.dirname __FILE__
I18n.load_path += Dir["#{support_dir}/active_support/locales/**/*.{rb,yml}"]