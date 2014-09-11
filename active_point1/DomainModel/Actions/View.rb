class View < Action	
	attr_accessor :form

	def execute
		begin
			f = form.new :metadata => self
		rescue Exception => e
			log.error "Can't initialize the #{form} Form!"
			raise e
		end
		controller.view = f
		view.values = object		
		finish
	end
end