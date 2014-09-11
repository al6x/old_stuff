class UpdateValues
	
	def initialize params; @params = params end
	
	def accept w
		if w.is_a?(Core::InputWiget) and !w.disabled? and w.visible? and (value = @params[w.component_id])
			w.update_value value
		end
    end
end