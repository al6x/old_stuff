// // 
// // Css
// // 
// css.add({
//   // App layout
//   // '.the_aspects':        {autoWidth: '.the_tools'},
//   // '.the_content':        {autoWidth: '.the_tools'},
//   // '.the_bottom_panel':   {clear:     'before'},  
// });
// (function(){
//   // max-width  
//   var maxWidth = 1024;
//   var increaseProperty = function(e, style, value){e.setStyle(style, e.getStyle(style).toInt() + value);};
//   var updateMargin = function(diff){    
//     // aspects, content, tools
//     var left = $$('.the_content, .the_aspects');
//     var right = $$('.the_tools');
//     if(right.blank()) right = left;
//     left.each(function(e){increaseProperty(e, 'margin-left', diff)});
//     right.each(function(e){increaseProperty(e, 'margin-right', diff)});
// 
//     // panels
//     $$('.the_top_panel .l_left, .the_bottom_panel .l_left, .the_navigation').each(
//       function(e){increaseProperty(e, 'margin-left', diff)}
//     );
//     $$('.the_top_panel .l_right, .the_bottom_panel .l_right').each(
//       function(e){increaseProperty(e, 'margin-right', diff)}
//     );
//   };  
//   
//   css.customCss = function(){
//     // show tools
//     $$('.the_top_panel, .the_bottom_panel, .the_navigation, .the_tools, .the_aspects').show();
//     
//     // max-width      
//     var previousDiff = window.retrieve('previousDiff') || 0;
//     var diff = ((window.getSize().x - maxWidth) / 2).toInt();
//     var diff = diff < 0 ? 0 : diff;    
//     diff = diff - previousDiff;    
//     if((diff + previousDiff) >= 0){
//       p(diff)
//       window.store('previousDiff', diff + previousDiff);
//       updateMargin(diff);
//     };
// 
// 
//     // // hack for top & bottom panels outside background
//     // (function(){
//     //   (['the_top_panel', 'the_bottom_panel']).each(function(name){
//     //     var hack_class = name + '_hack';
//     //     var panel = $$('.' + name).first();
//     //     var hack = $$('body > .' + hack_class).first();
//     //     if(panel){        
//     //       if(!hack){
//     //         hack = new Element('div', {'class': hack_class});
//     //         hack.inject(document.body);
//     //       }
//     //       hack.setStyles({'height': panel.getSize().y, 'top': panel.getPosition().y});
//     //     }else if (hack){
//     //       hack.destroy();
//     //     }
//     //   });
//     // }.delay(10));
//   };
// })();
// 
// window.addEvent('updateStyle', function(){
//   css.removeClearfixes();
//   css.customCss();
//   css.addClearfixes();
//   css.updateCss();  
// });


// 
// Initializers
// 
window.addEvent('updateStyle', function(){  
  // Discussion
	var discussion = $$('.the_discussion').first();
	if(discussion && discussion.getElement('.the_comment')){
		var divider = discussion.getElement('.the_divider')
		if(divider) divider.show();
	};
	
  // Hover Controls
	$$('.m_hover_controls').applyOnce('m_hover_controls', function(e){
	  var parent = e.getParent();
	  parent.setStyle('position', 'relative');
		parent.hover(
			function(){e.show()},
			function(){e.hide()}
		);
	});
		
  // Border around Items
  $$('.m_selectable').applyOnce('m_selectable', function(e){
    e.hover(
       function(){this.addClass('m_selectable_hover')},
       function(){this.removeClass('m_selectable_hover')}
     );
  }); 
    
  // Development only
  // $$('*').each(function(e){
  //   if(e.classNames().any(function(c){return c.match(/the_/)})){
  //     e.addClass('dev_border');
  //   };
  // });
});

// // 
// // Folder
// //
// // Empty title
// $.addOnceForElementEvent('update', 'empty_folder_title', '.folder', function(){
// 	$(this).hover(
// 		function(){
// 			$(this).find('> .empty_title').show()
// 		},
// 		function(){
// 			$(this).find('> .empty_title').hide()
// 		}
// 	);
// });
// 
// 