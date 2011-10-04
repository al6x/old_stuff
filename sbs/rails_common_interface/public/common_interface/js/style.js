// 
// Images by default should be alligned to the left (wrapped inside .left div)
// 
$.callOnceForEvery('left_img_allign', '._markup', function(){	
	var markup = $(this);
	var imagesWithoutDiv = markup.find('img').not(markup.find('div img'));
	imagesWithoutDiv.each(function(){
		var e = $(this);
		// image can be wrapped inside link
		while(true){
			var parent = e.parent();
			if(parent.hasClass('_markup') || !(parent.is('a') || parent.is('div') || parent.is('span'))) break;			
			e = parent;
		}
		e.wrap($("<div class='left'></div>"));
	});
});


// 
// Image Box inside Markup
// 
$.callOnceForEvery('markup_image_box', '._markup', function(){
	var markup = $(this);
	
	// Images
	markup.find('a:has(img)').not('._video').not('._nobox').attr('rel', 'images').fancybox();
	
	// Videos
	markup.find('a._video').click(function() {
		$.fancybox({
			'padding'		: 0,
			// 'autoScale'		: false,
			'transitionIn': 'none',
			'transitionOut': 'none',
			'title': this.title,
			// 'width'		: 680,
			// 'height'		: 495,
			'href': this.href.replace(new RegExp("watch\\?v=", "i"), 'v/'),
			// 'href'			: "http://www.youtube.com/watch?v=M-cIjPOJdFM&amp;fs=1".replace(new RegExp("watch\\?v=", "i"), 'v/'),				
			'type': 'swf',
			'swf': {
				'wmode': 'transparent',
				'allowfullscreen'	: 'true'
			}
		});

		return false;
	});
});
