require 'ObjectModel/require'

require 'RubyExt/Localization/require'
require 'WGUIExt/require'

module OMExt
	extend RubyExt::ImportAll
	import_all ObjectModel	
	
	Metadata::ATTRIBUTE_TYPES_SHORTCUTS.merge!({
		:locale => Locale::LocaleType,
		:richtext => Richtext::RichtextType,
	})
end