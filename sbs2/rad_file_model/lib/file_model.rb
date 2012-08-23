module FileModel; end

require 'vfs'
require 'ruby_ext'

%w(
  gems
  version
  helper
  adapter
  file_model
  mini_magic
).each{|f| require "file_model/#{f}"}

FileModel.include FileModel::MiniMagic
FileModel::Version.include FileModel::MiniMagic