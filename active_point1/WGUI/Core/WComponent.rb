class WComponent < Wiget
	include WigetContainer									
	
	# If template exist - uses it, if not uses default one.
	def to_html				
		html = if visible?
			#			if Utils::TemplateHelper.template_exist? self.class
			html = Utils::TemplateHelper.render_template self.class, :binding => binding, :preprocessing => true
			#			else
			#				html = Utils::TemplateHelper.render_template(WComponent, :binding => binding, :resource => "default.#{TEMPLATE_EXTENSION}")
			#			end
		else
			""
		end
		return Utils::TemplateHelper.render_template(WComponent, :binding => binding,
																								:resource => "wrapper.#{TEMPLATE_EXTENSION}")
	end				
	
	def subflow wiget, &answer_action		
		parent_continuation.subflow wiget, &answer_action
	end
	
	def answer value = nil
		parent_continuation.answer value
	end
	
	def cancel
		parent_continuation.cancel
	end	
	
	protected
	def parent_continuation
		p_cont = Scope[Engine::Window].visit(Engine::Visitors::ParentContinuation.new(self)).result
		raise "You can 'subflow or answer' only inside WContinuation container!" unless p_cont
		return p_cont
	end
end