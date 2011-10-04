class Development
	inherit Log
	inherit Controller	
	
	class DataObject
		attr_accessor :code_to_evaluate
	end
	
	def initialize
		super
		@data_object = DataObject.new
	end
	
	def show
		@view = ShowDevelopment.new.set! :object => C.object, :data_object => @data_object
	end
	
	def eval_code
		@view.collect_inputs
		begin
			eval @data_object.code_to_evaluate, binding, __FILE__, __LINE__
			C.messages.info "Code has beend evaluated successfully!"
		rescue Exception => e
			log.error e
			C.messages.error e.message
		end
	end
	
	secure :show => :development,
	:eval_code => :development
end