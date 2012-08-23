// 
// rad.require '/lib/rad.js'
// 
// rad.require '/vendor/mootools-more.js'
// 
// rad.require '/vendor/iFrameFormRequest.js'
// rad.require '/vendor/purr/purr.js'
// rad.require '/vendor/flext.js'
// rad.require '/vendor/formalize/mootools.formalize.js'
// 
// rad.require '/lib/SimpleDialog/SimpleDialog.js'
// rad.require '/lib/SimpleDialog/SimpleDialog.Mask.js'
// rad.require '/lib/SimpleDialog/SimpleDialog.Image.js'
// rad.require '/lib/SimpleDialog/SimpleDialog.ContextMenu.js'
// 
// rad.require '/lib/ajax_file_uploading.js'
// 
// rad.require '/face/tabs.js'
// rad.require '/face/table.js'
// rad.require '/face/more.js'
// rad.require '/face/markup.js'
// rad.require '/face/dialogs.js'
// rad.require '/face/discussion.js'
// rad.require '/face/attachments.js'
// 
// rad.require '/themes/default/style.js'
// 

Rad.implement({
  // Table
  table: function(tableQ){return new Rad.Table(tableQ);},
  
  // Messages
  info: function(message){Rad.messages.alert(message, {'highlight': false});},
  error: function(message){Rad.messages.alert(message, {'highlight': false, 'hideAfter': false, 'className': 'error'});},
  
  // Dialog
  dialog: function(){
    return new Rad.Dialog();
  },
  
  // Inplace Editor
  inplace: function(elementQ){
    return new Rad.EditInplace(elementQ);
  },
  
  // Context Menu
  contextMenu: function(){
    return new Rad.ContextMenu()
  },
  
  // Discussion
  discussion: function(){
    return new Rad.Discussion();
  }
});

// Messages
Rad.messages = new Purr({'mode': 'bottom', 'position':	'right'});


// 
// Initializations
// 
window.addEvent('updated', function(){
  // more button
  $$('.the_more').applyOnce('the_more', function(more){new Rad.More(more)});
  
  // markup
  $$('.m_markup').applyOnce('m_markup', function(e){new Rad.Markup(e)});
  
  // tabs
  $$('.the_tabs').applyOnce('the_tabs', function(e){new Rad.Tabs(e)});
  
  // context menu
  $$('.the_context_menu_button').applyOnce('the_context_menu_button', function(button){
    button.addEvent('click', function(event){
      event.stop();
      var content = $(button.getData('content_id'));      
      rad.contextMenu().show(event.page.x, event.page.y, content.get('html'))
    });
  });

  // autosubmitting changes
  $$('.m_autosubmit_on_change').applyOnce('m_autosubmit_on_change', function(e){
    e.addEvent('change', function(){
      rad.call(e.getData('action'), {
        value: e.get('value'),
        target: e.identify()
      });
    });
  });
  
  // form attachments
  $$('.the_attachments').applyOnce('the_attachments', function(e){new Rad.Attachments(e)});
});

window.addEvent('updateStyle', function(){
  // Flex TextArea
  $$('textarea').each(function(e){
    e.addClass('flext growme maxheight-400'); 
   new Flext(e);
  });
    
  // Table
  $$('.the_table').each(function(table){
    table.getChildren('tbody tr').removeClass('l_even');
    table.getChildren('tbody tr:even').addClass('l_even');
  });
});