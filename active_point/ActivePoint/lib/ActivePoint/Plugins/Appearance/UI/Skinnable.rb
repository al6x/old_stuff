module Skinnable
	inherit Controller
	
	def skin_set
		restore = @view				
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			skin = @view[:value].value			
			R.transaction{C.object.wc_skin = skin}.commit
			@view = restore
			@view.object = C.object
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh}		
		list = Skinnable.list_skin
		list << ""
		@view.object = {
			:value => C.object.wc_skin, :values => list, 
			:title => ActivePoint::Plugins::Appearance.to_l("Set Skin")
		}
	end
	
	secure :skin_set => :manage
	
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