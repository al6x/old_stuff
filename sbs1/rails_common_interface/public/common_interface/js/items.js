// 
// List
// 
$.callOnceForEvery('list', '._list', function(){
	var maxFinishedTasks = 3;
	
	var list = $(this);
	var container = list.find('._container:first');
	var show_more = list.find('._show_more');
	var show_less = list.find('._show_less');
	var hidden_tasks = list.find('._hidden_tasks');	

	// Hide Finished Tasks if ther's more than 3
	var hide_tasks = function(){
		var lastNotFinishedTask = container.find('> ._item:not(._finished):last');
		if(!lastNotFinishedTask.blank()){
			var tasks = container.find('> ._item');
			var lastNotFinishedTaskIndex = tasks.index(lastNotFinishedTask);		
			var finishedTasks = tasks.slice(lastNotFinishedTaskIndex, -1);

			if(finishedTasks.size() > maxFinishedTasks){			
				show_more.show();
				var tasksToHide = tasks.slice(lastNotFinishedTaskIndex + maxFinishedTasks, -1);
				tasksToHide.remove().appendTo(hidden_tasks);
			} 
		}
	};
	hide_tasks();
	 
	
	// Initialize more/less buttons
	show_more.click(function(){
		hidden_tasks.find('._item').appendTo(list.find('._container'));
		show_more.hide();
		show_less.show();
		return false;
	});
	
	show_less.click(function(){
		hide_tasks();
		show_less.hide();
		return false;
	});
});


// 
// Sortable
// 
$.callAfterUpdate('sortable', function(){
	$('._sortable_container').each(function(){
		var container = $(this);
		var opt = {
			item_class: container.dataAttr('item_class'),
			update_order_url: container.dataAttr('update_order_url')
		};
		
		container = container.find('._container').not(container.find('._container ._container'));
		
		container.sortable({
			handle: '._handle', 
			items: '> .' + opt.item_class,
			update: function(event, ui) {
				var item = $(ui.item);
				var index = container.find('.' + opt.item_class).index(item);
				// var url = page.dataAttr('container_order_url')
				if(opt.update_order_url){
					$.post(opt.update_order_url, {index: index, item_id: item.attr('id')})
				}else{
					log("Item '" + item.identify() + "' moved to position '" + index + "'.")
				};
			}			
		});
	});		
});


// 
// Folder
// 
// Image View Box
$.callOnceForEvery('folder_image_box', '._folder', function(){
	var folder = $(this);
	var links = folder.find('a._image_box');
	links.attr('rel', 'images');
	links.fancybox();
});

// 
// Page
// 
// Toolbars
$.callAfterUpdate('page_toolbar', function(){
	$('._page').each(function(){
		var page = $(this);
		var container = page.find('._container').first();
		
		container.find('._toolbar').remove();		
		
		var toolbar_html = page.find('._toolbar_template').val();		
		container.find('> ._item:visible, > ._inplace').each(function(){
			$(this).after(toolbar_html);
		});
		container.prepend(toolbar_html);
	});
}, 1);


// 
// Checkbox
// 
// Onclick
$.callOnceForEvery('onclick_for_checkbox', '._onclick_checkbox', function(){
	var checkbox = $(this);
	checkbox.click(function(){
		$.ajax({data: $.param({target: checkbox.identify()}), type: 'post', url: checkbox.dataAttr('url')});
	});
});