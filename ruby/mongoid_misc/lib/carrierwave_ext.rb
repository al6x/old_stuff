require 'carrierwave'
require 'carrierwave/validations/active_model'
require 'carrierwave/orm/mongoid'

%w(
  fixes
  miscellaneous
  mongoid_embedded
).each{|f| require "carrierwave_ext/#{f}"}

CarrierWave::Uploader::Base.class_eval do
  def name; model.send("#{mounted_as}_filename") end
end

Mongoid::Document.class_eval do
  include CarrierWave::MongoidEmbedded  
end