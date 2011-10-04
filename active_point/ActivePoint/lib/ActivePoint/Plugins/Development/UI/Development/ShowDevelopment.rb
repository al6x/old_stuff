class ShowDevelopment < WComponent
	inherit Form
	
	attr_accessor :data_object
	
	def inputs
		@inputs ||= {}
	end
	
	build :tab, :css => "padding" do
		set! :active => "Eval", :title => "Development"
		add "Eval", :box, :css => "padding" do
			form.inputs[:code_to_evaluate] = text_edit :value => form.data_object.code_to_evaluate
			button :text => "Eval", :action => [form, :eval_code]
		end
	end
	
	def collect_inputs
		data_object.code_to_evaluate = inputs[:code_to_evaluate].value
	end
end