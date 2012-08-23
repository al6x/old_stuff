# require 'mime/types' TODO1 use Mime from Rack
require 'paperclip'

%w(
  fixes
  mime
  callbacks
  integration
  extensions
  validations
).each{|f| require "kit/paperclip/#{f}"}
# 'mime