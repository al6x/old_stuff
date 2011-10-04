// requirements
railsExt;

// 
// More
// 
$._opened_more_containers = {};
$.callOnceForEvery('more', '._more', function(){
	var more = $(this);
	var button = more.find('._button:first');
	var content = more.find('._content:first');

	// more button
	button.click(function(){
		$._opened_more_containers[more.attr('id')] = true;
		more.replaceWith(content.contents()); 
		$.processInitializers();
		return false
	});
	
	// if opened once, keep it open in all next ajax updates	
	if($._opened_more_containers[more.attr('id')]){
		more.replaceWith(content.contents()); 
		$.processInitializers();
	};
});

// 
// Messages
// 
$.jGrowl.defaults.position = 'bottom-right'
$.extend({
	infoMessage: function(message){
		this.jGrowl(message);
	},
	
	errorMessage: function(message){
		this.jGrowl(message);
	}
});


// 
// Inplace Editor
// 
$.callOnceForEvery('inplace', '._inplace', function() {
	var inplace = $(this);
	var id = inplace.dataAttr('original_id');
	if(!id) warn("inplace original_id isn't defined!");
	
	// Universal Cancel Button (for General and AJAX forms)
	inplace.find('._redirect_back_or_close_dialog').click(function(){				
		inplace.remove();
		$('#' + id).show();
		$.processInitializers();
		return false;
	});

	// Universal Submit Button (for General and AJAX forms)
	inplace.find('._submit_form_or_ajax_form').click(function(){
		var form = inplace.find('form');
		
		var data = {
			format: 'js',
			target: $(this).identify(),
		};
		
		// Calculating index inside container (only if it's inside container)
		if(!inplace.parents('._container').blank()){
			var container = inplace.parents('._container').first();
			var list = container.find('> ._item, #' + inplace.identify());
			var index = list.index(inplace);
			data['index'] = index;
		}

		form.ajaxSubmit({data: data, dataType: 'script'});
		
		return false;
	});
});

$.fn.extend({
	add_inplace: function(container, html, add_method){		
		var target = $(this).parents('._inplace_target');
		if(!target.blank()){
			target.after(html);
		}else{						
			// if($(container + ' ._inplace._new_inplace').blank()) {
			// var inplace = $(html).addClass('_new_inplace');
			var inplace = $(html);
			var container = $(container);
			add_method = add_method || 'append';
			container[add_method](inplace);
			// }
		}
	},
	
	edit_inplace: function(id, html){
		var inplace = $(html);
		inplace.dataAttr('original_id', id);
		
		var original = $('#' + id);
		original.hide();
		
		var previous_inplace = $(this).parents('._inplace');
		if(!previous_inplace.blank()){
			previous_inplace.replaceWith(inplace);
		}else{
			original.after(inplace);
		}		
	}, 
	
	update_inplace: function(id, html){
		var original = $('#' + id);
		original.remove();
		
		var previous_inplace = $(this).parents('._inplace');
		previous_inplace.replaceWith(html);
	}
});


// 
// Dialog
// 
$.callOnceForEvery('dialog', '._dialog', function() {
	// Universal Form Cancel Button (for General and AJAX forms)
	var dialog = $(this);
	dialog.find('._redirect_back_or_close_dialog').click(function(){
		dialog.remove();
		return false;
	});

	// Universal Submit Button (for General and AJAX forms)
	dialog.find('._submit_form_or_ajax_form').click(function(){
		dialog.hide();
		
		var form = dialog.find('form');		
		form.ajaxSubmit({
			data: {
				format: 'js'
			}, 
			dataType: 'script',
			success: function(){
				dialog.remove(); // can be removed only when form is posted, othervise it doesn't works with files
			}
		});
		
		return false;
	});

	// Center dialog
	var winH = $(window).height();  
	var winW = $(window).width();  
	var scroll_top = $(window).scrollTop();
	var layoutW = $('._layout_content').width();  
	dialog.css('top',  winH/3 + scroll_top - dialog.height()/2);  
	dialog.css('left', layoutW/2 - dialog.width()/2);
	// More about cool modal dialog: http://www.queness.com/post/77/simple-jquery-modal-window-tutorial
});

$.fn.extend({
	showDialog: function(dialogHtml){		
		$('._dialog').remove();
		$('._main').append(dialogHtml);
		
		$.refresh_js_css();
	}
});

// 
// Popup
// 
$.callOnceForEvery('popup', 'body', function() {
	$(this).click(function(){
		$('._active_popup').remove();
	});
});

// Embedded popup (popup without AJAX)
$.callOnceForEvery('embedded_popup', '._embedded_popup', function() {
	var e = $(this);
	e.click(function(){
		var content = $("#" + e.dataAttr('content_id'));		
		e.showPopup(content.html());
		return false;
	});
});

// showPopup
$.fn.extend({
	showPopup: function(popupHtml){
		if(popupHtml.blank()){
			log("Content for PopUp is blank!");
			return;
		}
		
		$('._active_popup').remove();		
		var popup = $(popupHtml) 
		popup.addClass('_active_popup');
		$('._main').append(popup);
				
		$.refresh_js_css();
		
		// Positioning
		var layout_content = $('._layout_content');
		
		var left = $(this).offset().left + this.width() / 2;
		var top = $(this).offset().top + this.height() / 2;
		
		var border_bottom = $(window).scrollTop() + $(window).height();
		var border_right = layout_content.width();
		var left_pos, top_pos;
		var offset = 5;
		if(border_right - (offset * 2) >= left + popup.width()){
			left_pos = left + offset;
		}else{
			left_pos = border_right - popup.width() - (offset * 3);
		}
		
		if(border_bottom + (offset * 2) >= top + popup.height()){
			top_pos = top + offset;
		}else{
			top_pos = top - popup.height() - offset;
		}	
		
		popup.css({left:left_pos, top:top_pos});		
	}
});