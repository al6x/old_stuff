require 'utils/open_constructor'
include Utils

class WikiModel
	include OpenConstructor
	attr_accessor :name, :text, :image, :file
end
	
class WikiService < Hash
	private_class_method :new
		
	def self.instance; @instance ||= new end
		
	def initialize
		self['Page 1'] = WikiModel.new.set(:name => 'Page 1', :text => "Page 1 text\nLine 1")
		self['Page 2'] = WikiModel.new.set(:name => 'Page 2', :text => "Page 2 text\nLine 1")
		self['Page 3'] = WikiModel.new.set(:name => 'Page 3', :text => "Page 3 text\nLine 1")
		@home = WikiModel.new.set(:name => 'Home', :text => "Home page\nLine 1")
	end
		
	def home; @home end
end		