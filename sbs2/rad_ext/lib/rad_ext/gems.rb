# core gems
gem 'redcarpet', '~> 2.0'
gem 'sanitize',  '~> 2.0'
gem 'nokogiri',  '~> 1.4'
gem 'recaptcha', '~> 0.3'

if respond_to? :fake_gem
  fake_gem 'rad_core'
  fake_gem 'rad_common_interface'
  fake_gem 'mongodb_model'
end

# TODO2 remove dependencies

# old
# gem 'bluecloth',     '2.0.9'
# gem 'paperclip',     '2.3.1.1'
# gem 'coderay',       '0.9.7'
