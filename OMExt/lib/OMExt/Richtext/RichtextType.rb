class RichtextType < Types::ObjectType
	class << self
		def initial_value m, e
			WGUIExt::Editors::RichTextData.new
		end
		
		def validate_type value
			value.is_a? WGUIExt::Editors::RichTextData
		end
	end
end