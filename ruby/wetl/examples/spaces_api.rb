require 'active_resource'
require 'rest_client'

ActiveResource::Base.class_eval do
  def encode(options={})
    case self.class.format
      when ActiveResource::Formats[:xml]      
        self.class.format.encode(attributes, {:root => self.class.element_name}.merge(options))
      when ActiveResource::Formats::JsonFormat
        self.class.format.encode({self.class.element_name => attributes}, options)
      else
        self.class.format.encode(attributes, options)
    end
  end
end

class SpacesResource < ActiveResource::Base
  self.format = :json  
  
  def self.rest_client
    @rest_client = RestClient::Resource.new site, :user => user, :password => password
  end
  def rest_client; self.class.rest_client end
end

class Item < SpacesResource
  def set_visibility visibility
    post(:visibility, :visibility => visibility)
  end
  
  def icon= file
    file.should! :be_a, File
    rest_client["items/#{slug}/icon"].post :item => {:icon => file}, :format => :json
  end
  
  def add item, opt = {}
    post :add, {:item_id => item.to_param}.merge(opt)
  end
  
  def to_param; slug.to_s end  
end

class Page < Item
end

class Note < Item
end

class Folder < Item
  def add item, opt = {}    
    super item, {:collection => :files}.merge(opt)
  end
end

class IFile < Item
  self.element_name = "file"
  
  def file= file
    file.should! :be_a, File
    rest_client["files/#{slug}"].put :file => {:file => file}, :format => :json
  end  
end