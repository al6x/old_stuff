// 
// Discussion
// 
$.callAfterUpdate('discussion', function(){
	var discussion = $('.ddiscussion');
	if(!discussion.blank() && !discussion.find('.dcomment').blank()) discussion.find('.ddivider').show();
});

// 
// JS for CSS
// 
$.refresh_js_css = function(){
	try{
		Elastic.refresh();
	}catch(e){
		log("Elastic not defined!");
	};
}


// 
// Border around nested Items
// 
$.callOnceForEvery('selectable_item', '.dselectable_item', function(){
	var item = $(this);
	if(!item.parents('._item').blank()){
		$(this).addClass('dselectable_item_padding');
		$(this).hoverIntent(
			function(){$(this).addClass('dselectable_item_hover')},
			function(){$(this).removeClass('dselectable_item_hover')}
		);
	}
});


// 
// Hover Controls
// 
$.callOnceForEvery('dhover_controls_container', '.dhover_controls_container', function(){
	$(this).hoverIntent(
		function(){$(this).find('> .dhover_controls').show()},
		function(){$(this).find('> .dhover_controls').hide()}
	);
});


// 
// Folder
//
// Empty title
$.callOnceForEvery('empty_folder_title', '.folder', function(){
	$(this).hover(
		function(){
			$(this).find('> .empty_title').show()
		},
		function(){
			$(this).find('> .empty_title').hide()
		}
	);
});


// 
// Table
// 
$.callOnceForEvery('oddlines', '._table ._row:odd', function(){
	$(this).removeClass('deven').addClass('dodd');
});
$.callOnceForEvery('even_lines', '._table ._row:even', function(){
	$(this).removeClass('dodd').addClass('deven');
});


// 
// Elastic
// 
$.callAfterUpdate('elastic', function(){$.refresh_js_css();}, 1);


// 
// Flex TextArea
// 
// callOnceForEvery doesn't works, becouse flex textarea doesn't works for hidden textareas that are resides inside 'more' button.
$.callAfterUpdate('autoresize_textarea', function(){$('textarea').elastic();});