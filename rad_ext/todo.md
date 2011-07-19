# MongoMapper











# Refactoring

## Rad
	HTML		
		+ initialize_js_commons
		+ redirect_to (with AJAX)
		+ global_path_prefix
		+ render_action
		+ js		
		+ flash (with AJAX)
		+ protect_from_forgery
		+ default_path, return_to_path
		+ reload_page
		
	Remote
		+ persistent_params (persist_params, dont_persist_params, global_persistent_params)	
		
	Render
		+ prepent_to, wrap_content_for, has_content_for

	Email
		+- email
		
	Environment
		+ config files, safe_hash


## Rad-Ext
	Remote		
		+ UserError, raise_user_error, catch_user_error
		+ prepare_model
				
	Environment				
		+- email config
		
	HTML				
		+ defer_static_scripts		
	
	Rad
		+ i18n
		

## Other
	+ ensure_no_www


## Deprecated:
	link_to for controller
	stages