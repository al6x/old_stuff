require 'wgui/wgui'
include WGUI

require 'wgui/spec/examples/wiki/business_logic'

class WikiPageEditor < WComponent
	attr_accessor :model
	def initialize model
		super nil
		self.model = model
		@name = TextField.new self, ""
		@text = TextArea.new self, ""
		@image = FileUpload.new self
		@file = FileUpload.new self
		@ok = Button.new self, 'Ok', self do
			model.name, model.text = @name.text, @text.text						
			unless @image.empty?
				data = StringIO.new
				@image.file.each{|part| data.write part}
				model.image = ResourceData.new(
					@image.resource_id, IOWrapper.new(data), @image.size, @image.extension
				)
            end			
			unless @file.empty?
				data = StringIO.new
				@file.file.each{|part| data.write part}
				model.file = ResourceData.new(
					@file.resource_id, IOWrapper.new(data), @file.size, @file.extension
				)
            end		
			answer
		end
		@cancel = Button.new self, 'Cancel' do
			answer
		end
		template 'xhtml/WikiPageEditor'	
	end
		
	def render
		@name.text, @text.text = model.name, model.text		
	end	
end
	
class WikiPage < WComponent
	attr_accessor :model
	def initialize p
		super p
		@name = Label.new self, ""
		@text = Label.new self, ""
		@image = WImage.new self, nil
		@file = WResource.new self, nil
		@edit = Button.new self, 'Edit' do
			subflow WikiPageEditor.new(model)
        end
		template 'xhtml/WikiPage'
	end		
		
	def render
		@name.text, @text.text, @image.data, @file.data = model.name, model.text, model.image, model.file
	end			
end