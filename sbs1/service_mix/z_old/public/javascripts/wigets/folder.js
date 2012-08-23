// Folder
(function($){
	// var files = [];
	// var initializers = [];
	// var id = 0;
	// function nextId(){return id++ };
	
	Folder = function(params, encrypted_secure_params, visual_params){
		this.params = params;
		this.secure_params = encrypted_secure_params;
		this.visual_params = visual_params;
		
		var _this = this;
		$.add_deferred_initializer(function(){_this.initialize()});
		
		// 
		// this.id = nextId();
		// 
		// files[this.id] = this;
	};
	var _this = Folder;
	
	// _this.initialize = function(fun){
	// 	initializers.push(fun);
	// };
	
	// _this.render = function(){
	// 	if(files.size() == 0) return;
	// 
	// 	var json_params = {};
	// 	$.each(files, function(k, v){
	// 		json_params[v.id] = v.params;
	// 	})
	// 	
	// 	sm.ajax(
	// 		'get',
	// 		"/wigets/folder.json", 
	// 		{json_params: $.toJSON(json_params)}, 
	// 		function(data){_this.renderCallback(data)}
	// 	)
	// };
	
	// _this.renderCallback = function(data){
	// 	$.each(files, function(k, v){
	// 		v.renderCallback(data);
	// 	})
	// };
		
	Folder.prototype = {
		// render: function() {
		// 	var json_params = {};
		// 	json_params[this.id] = this.params;
		// 
		// 	var _this = this;
		// 	sm.ajax(
		// 		'get',
		// 		"/wigets/folder.json", 
		// 		{json_params: $.toJSON(json_params)}, 
		// 		function(data){_this.renderCallback(data)}
		// 	)
		// },
			
		// renderCallback: function(data) {
		// 	var _this = this;
		// 	
		// 	var data = data[this.id];
		// 	var vp = this.visual_params;
		// 	
		// 	var wiget = $(vp.wiget);
		// 	var content = wiget.find('._content');
		// 	wiget.find('._content').empty();
		// 	
		// 	if(data.can_view) {
		// 		content.append(wiget.find('._content_template').val());
		// 		
		// 		// add files
		// 		var t = $.template(wiget.find('._file_template').val());
		// 		$.each(data.files, function(k, file){		
		// 			var fileId = '_file_' + file.id;
		// 			var values = $.extend({'delete': data.labels['delete'], file_id: fileId}, file);
		// 			content.find('._files').append(t, values);
		// 			
		// 			var fileItem = content.find('._files').find('.' + fileId);
		// 			fileItem.find('._delete').click(function(){
		// 				var params = $.extend({file:{id: file.id}}, _this.params);
		// 				
		// 				sm.ajax(
		// 					'delete',
		// 					"/wiget/folder/id.json", 
		// 					{json_params: $.toJSON(params)}, 
		// 					function(data){_this.render()}
		// 				)
		// 			})
		// 		})
		// 		
		// 		this.renderSwfupload(data, vp, wiget, content);
		// 		
		// 		// this.initialize(data)
		// 	}
		// 	
		// 	if(!data.can_edit){
		// 		content.find('._delete').hide();
		// 	}
		// },
		
		initialize: function(){
			var _this = this;
			
			// Escape params
			var params = $.extend(
				{format: 'json'}, 
				sm.base_params, 
				sm.flash_params, 
				{json_params: $.toJSON(this.params), secure_params: this.secure_params}
			);
			// var escapedParams = {}
			// $.each(params, function(k, v){
			// 	if(k == 'session_value'){
			// 		escapedParams[k] = encodeURIComponent(v)
			// 	}else{
			// 		escapedParams[k] = v
			// 	}
			// })
			
			// Initialize flash
			var content = $('._folder_dialog');
			var flashHolder = content.find('._flash_holder');
			
			var flash_params = {
				upload_url: sm.serviceUrl('/wigets/folders/create_file?'+$.param(params)),
				file_post_name: 'item[file]',
				// file_size_limit : "1024",
				// file_types : "*.jpg;*.png;*.gif",
				// file_types_description : "Image files",
				file_upload_limit : 10,
				flash_url : sm.serviceUrl('/plugins/jquery.swfupload/swfupload/swfupload.swf'),
				
				button_text : this.visual_params.select_files,
				// button_image_url : sm.serviceUrl('/plugins/jquery.swfupload/swfupload/wdp_buttons_upload_61x22.png'),

				// button_text : '<span class="btnText">Select Files...</span>',
				// button_text_style : ".btnText { font-size: 10; font-weight: bold; font-family: MS Shell Dlg; }",
				// button_text_top_padding : 3,
				// button_text_left_padding : 100,
				
				button_width : 61,
				button_height : 22,
				button_placeholder : content.find('._flash_holder')[0],
				prevent_swf_caching: false,
				debug: false
			};
			
			var flash_wrapper = flashHolder.swfupload(flash_params);
			
			flash_wrapper
				.bind('fileQueued', function(event, file){
					var params = $.extend({}, file, {
						size_in_kb: Math.round(file.size/1024)
					})
					
					var t = $.template(content.find('._file_progress_template').val())
					content.find('._queue').append(t, params);
					var fileItem = content.find('._file_'+file.id)
					fileItem.find('._cancel').bind('click', function(){
						// var swfu = $.swfupload.getInstance(vp.wiget + ' ._flash_holder');
						flashHolder.swfupload('cancelUpload', file.id);
						fileItem.slideUp('fast');
					});
					// start the upload since it's queued
					// $(this).swfupload('startUpload');
				})
				.bind('fileQueueError', function(event, file, errorCode, message){
					alert('Size of the file '+file.name+' is greater than limit');
				})
				// .bind('fileDialogComplete', function(event, numFilesSelected, numFilesQueued){
				// 	$('#queuestatus').text('Files Selected: '+numFilesSelected+' / Queued Files: '+numFilesQueued);
				// })
				.bind('uploadStart', function(event, file){
					var fileItem = content.find('._queue ._file_' + file.id)
					fileItem.find('._progressvalue').text('0%');
					fileItem.find('._cancel').hide();
				})
				.bind('uploadProgress', function(event, file, bytesLoaded){
					var percentage=Math.round((bytesLoaded/file.size)*100);
					var fileItem = content.find('._queue ._file_' + file.id)
					fileItem.find('._progress').css('width', percentage+'%');
					fileItem.find('._progressvalue').text(percentage+'%');
				})
				.bind('uploadSuccess', function(event, file, data){
					var json = eval( "(" + data.toString() + ")" );	
					$.checkForMessages(json);

					var fileItem = content.find('._queue ._file_' + file.id);
					fileItem.find('._progress').css('width', '100%');
					fileItem.find('._progressvalue').text('100%');
					fileItem.slideUp('fast');
				})
				// .bind('uploadComplete', function(event, file){
				// })
				.bind('queueComplete', function(){
					$.ajax({
						data: $.param({id: _this.params.folder_id, format: 'js'}), 
						dataType: 'script', 
						type: 'get', 
						url: _this.params.refresh_url
					});
					
					$.infoMessage(_this.visual_params.files_upload_complete);
					$('._dialog').remove();
				});
						
			// 'Upload' button
			content.find('._upload').click(function(){
				flashHolder.swfupload('startUpload');
				return false;
			});
		}
	}
})(jQuery);