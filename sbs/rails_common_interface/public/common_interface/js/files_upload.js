// Files Upload
(function($){
	FilesUpload = function(params, opt){
		this.params = params;
		this.opt = opt;
		
		var _this = this;
		$.callOnceAfterUpdate('file_upload', function(){_this.initialize()});
	};
	var _this = FilesUpload;
			
	_this.prototype = {
		initialize: function(){
			var _this = this;
			
			// Escape params
			var params = $.extend({format: 'js', authenticity_token: $.authenticity_token}, this.params)
			
			// Initialize flash
			var content = $('._upload_dialog');
			var flashHolder = content.find('._flash_holder');
			
			var upload_url = decode_uri(this.opt.upload_url);
			upload_url = (upload_url.indexOf('?') >= 0) ? (upload_url + '&'+$.param(params)) : (upload_url + '?'+$.param(params));
			
			var flash_params = {
				upload_url: upload_url, 
				file_post_name: 'file[file]',
				// file_size_limit : "1024",
				// file_types : "*.jpg;*.png;*.gif",
				// file_types_description : "Image files",
				file_upload_limit : 20,
				flash_url : '/common_interface/lib/jquery.swfupload/swfupload/swfupload.swf',
				
				button_text : this.opt.select_files,
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
					var fileItem = content.find('._queue ._file_' + file.id);
					fileItem.find('._progress').css('width', '100%');
					fileItem.find('._progressvalue').text('100%');
					fileItem.slideUp('fast');
					
					data = data.replace('<textarea>', '').replace('</textarea>', '');
					eval(data.toString());
					$.refresh_js_css();
				})
				// .bind('uploadComplete', function(event, file){
				// })
				.bind('queueComplete', function(){					
					// $.ajax({
					// 	data: $.param({format: 'js'}), 
					// 	dataType: 'script', 
					// 	type: 'get', 
					// 	url: _this.opt.refresh_url
					// });
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