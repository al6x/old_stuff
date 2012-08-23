gem 'i18n',        '~> 0.6'
gem 'tilt',        '~> 1.3'
gem 'addressable', '~> 2.2'
gem 'rack',        '~> 1.3'
gem 'thin',        '~> 1.3'
gem 'mail',        '~> 2.3'
gem 'builder',     '~> 3.0' # need for :xml response

if respond_to? :fake_gem
  fake_gem 'ruby_ext'
  fake_gem 'vfs'
  fake_gem 'micon'
  fake_gem 'class_loader'
end

#
# Gems for specs
#
# gem 'nokogiri', '1.4.4'