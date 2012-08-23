// 
// Universal dialog form buttons
//
Rad.DialogButtons = new Class({
  _initializeButtons: function(containerQ){
    var container = containerQ.toElement(true);
    // Universal Cancel Button (for General and AJAX forms)
    container.getElements('.m_redirect_back_or_close_dialog').addEvent('click', function(event){
      event.stop();
      this.destroy();
    }.bind(this));
    
    // Universal Submit Button (for General and AJAX forms)
    container.getElements('.m_submit_form_or_ajax_form').addEvent('click', function(event){
      event.stop();
      this.submit();
    }.bind(this));
  }
});


// 
// Inplace
// 
Rad.AbstractInplace = new Class({
  Implements: [Events, Rad.DialogButtons],
  
  wait: function(message){
    message = message || "<p>Please wait ...</p>";
    this.editor.getChildren().hide();
    message.toElements(true).inject(this.editor);
  },
  
  submit: function(){
    this.wait();
    var form = this.editor.getElement('form');
    rad.submitForm(form, {}, function(){this.destroy();}.bind(this));
  },
  
  edit: function(editorQ){
    this.editor = editorQ.toElement(true); 
    this.editor.addClass('the_inplace_editor');
    this._initializeButtons(this.editor);
  }
});

Rad.EditInplace = new Class({
  Extends: Rad.AbstractInplace,
  
  initialize: function(elementQ){
    this.element = elementQ.toElement(true);
  },
  
  destroy: function(){
    this.element.show();
    this.editor.destroy();
    this.fireEvent('destroy');
  },
  
  edit: function(editorQ){
    this.parent(editorQ);
    
    this.element.hide();
    this.editor.inject(this.element, 'after');
        
    this.fireEvent('edit');
  },
  
  update: function(contentQ){
    var content = contentQ.toElements(true);
    content.replaces(this.element);
    this.fireEvent('update');
  }    
});

Rad.AddInplace = new Class({
  Extends: Rad.AbstractInplace,
  
  initialize: function(containerQ){
    this.container = containerQ.toElement(true);
  },
  
  destroy: function(){
    this.editor.destroy();
    this.fireEvent('destroy');
  },
  
  edit: function(editorQ){
    this.parent(editorQ);
    
    if(this.container) this.editor.inject(this.container);
    this.fireEvent('edit');
  },
  
  update: function(contentQ){
    var content = contentQ.toElements(true);
    content.inject(this.container);
    this.fireEvent('update');
  }
});


// 
// Dialog
// 
Rad.Dialog = new Class({
  Extends: SimpleDialog,
  Implements: [SimpleDialog.OnlyOne, Rad.DialogButtons],
  
  initialize: function(options){
    options = options || {}
    this.parent(options);
    this.element.addClass('the_dialog');
    this.onlyOne(this);
    new SimpleDialog.Mask(this);
  },
  
  show: function(html){
    this.parent(html);
    this._initializeButtons(this.element);
  },
  
  submit: function(){
    var form;
    this.wait();
    form = this.element.getElement('form');
    // form can be removed only when form is posted, othervise it doesn't works with files
    rad.submitForm(form, {}, function(){this.destroy();}.bind(this));
  }
});


// 
// Image dialog
//  
Rad.ImageDialog = new Class({
  Extends: SimpleDialog.Image,
  Implements: [SimpleDialog.Autodestroy, SimpleDialog.OnlyOne],
  initialize: function(options){
    options = options || {}
    this.parent(options);
    this.element.addClass('the_image_dialog');
    this.onlyOne(this);
    this.autodestroy();
    new SimpleDialog.Mask(this);
  }
});


// 
// Context menu
// 
Rad.ContextMenu = new Class({
  Extends: SimpleDialog.ContextMenu,
  Implements: [SimpleDialog.Autodestroy, SimpleDialog.OnlyOne],
  initialize: function(options){
    options = options || {}
    this.parent(options);
    this.element.addClass('the_context_menu');
    this.onlyOne(this);
    this.autodestroy();
  }
});


// TODO3 showVideosInDialog
// markup.getElements('a._video').addEvent 'click', (event) ->
//   event.stop()
//   Slimbox.open this.get('href'), this.get('title')
//     $.fancybox({
//       'padding'    : 0,
//       // 'autoScale'    : false,
//       'transitionIn': 'none',
//       'transitionOut': 'none',
//       'title': this.title,
//       // 'width'    : 680,
//       // 'height'    : 495,
//       'href': this.href.replace(new RegExp("watch\\?v=", "i"), 'v/'),
//       // 'href'      : "http://www.youtube.com/watch?v=M-cIjPOJdFM&amp;fs=1".replace(new RegExp("watch\\?v=", "i"), 'v/'),        
//       'type': 'swf',
//       'swf': {
//         'wmode': 'transparent',
//         'allowfullscreen'  : 'true'
//       }
//     });
// 
//     return false;
//   });
// });