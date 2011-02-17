class ObjectViewWiget < Wiget
	metadata do
		name "Object View Wiget"
	end
	
	def create_wiget_wrapper
		WGUIExt::Containers::Wrapper.new.set! :component => :controller, :accessor => :view,
		:css => "border_top border_left" # TODO hack
	end
end