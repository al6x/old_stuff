hash = Hash.new{|hash, key| raise "Invalid wiget alias '#{key}'!"}
hash.merge!({
	# Editors
	:boolean_view => WGUIExt::Editors::BooleanView,
	:boolean_edit => WGUIExt::Editors::BooleanEdit,
	
	:date_view => WGUIExt::Editors::DateView,
	:date_edit => WGUIExt::Editors::DateEdit,
	
	:file_view => WGUIExt::Editors::FileView,
	:file_edit => WGUIExt::Editors::FileEdit,
	
	:image_view => WGUIExt::Editors::ImageView,
	:image_edit => WGUIExt::Editors::ImageEdit,
	
	:list_view => WGUIExt::Editors::ListView,
	
	:number_view => WGUIExt::Editors::NumberView, 
	:number_edit => WGUIExt::Editors::NumberEdit, 
	
	:link => WGUIExt::Editors::ObjectLink,
	
	:richtext_view => WGUIExt::Editors::RichTextView,
	:richtext_edit => WGUIExt::Editors::RichTextEdit,
	
	:select => WGUIExt::Editors::Select,
	
	:string_view => WGUIExt::Editors::StringView,
	:string_edit => WGUIExt::Editors::StringEdit,		
	
	:text_view => WGUIExt::Editors::TextView,
	:text_edit => WGUIExt::Editors::TextEdit,

	# Containers
	:box => WGUIExt::Containers::Box,
	:line => WGUIExt::Containers::Line,
	:attributes => WGUIExt::Containers::Attributes,
	:border => WGUIExt::Containers::Border,
	:wrapper => WGUIExt::Containers::Wrapper,
	:tab => WGUIExt::Containers::Tab,
	:tab_js => WGUIExt::Containers::TabJS,
  :tab_url => WGUIExt::Containers::TabURL,
  :table => WGUIExt::Containers::Table,
	
	# Controls
	:button => WGUIExt::Controls::Button,
	:link_button => WGUIExt::Controls::LinkButton,
})
hash