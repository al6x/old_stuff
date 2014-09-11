module Skinnable
	def skin_set
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Set Skinnable"
		form.on_ok = lambda do						
			skin = form[:select].value			
			R.transaction{C.object.wc_skin = skin}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		list = Skinnable.list_skin
		list << ""
		form.parameters = {:values => list}
		form.object = {:select => C.object.wc_skin}
		view.subflow form
	end
	
	def skin_delete
		C.transaction_begin		
		R.transaction{
			C.object.wc_skin = ""
		}.commit
		view.object = C.object
		view.refresh
	end
	
	class << self
		def list_skin
			list = []
			Dir.glob("#{CONFIG[:skins_directory]}/**").each do |item| 
				list << File.basename(item) if File.directory? item
			end
			return list
		end
	end
end