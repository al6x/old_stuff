# 
# Because of Mongoid doesn't fires some events on embedded documents 
# (it has 'smart' callback system and doesn't fires :save/:destroy if document don't really saved/destroyed)
# we need to do it manually.
# 

Mongoid::Document.class_eval do
  def each_embedded association_name, &b
    Array(send(association_name)).each &b
  end
end

module CarrierWave::MongoidEmbedded
  extend ActiveSupport::Concern
  
  module ClassMethods
    def mount_embedded_uploader association_name, column
      after_save do |doc|
        doc.each_embedded(association_name) do |embedded|
          embedded.send "store_#{column}!"
        end
      end
    
      before_save do |doc|
        doc.each_embedded(association_name) do |embedded|
          embedded.send "write_#{column}_identifier"
        end
      end
    
      after_destroy do |doc|
        doc.each_embedded(association_name) do |embedded|
          embedded.send "remove_#{column}!"
        end
      end
    end
  end
end