// 
// Attachments
// 
// - if there's no any files in attachment it should display small file_input without any border or remove button
// - if there's files - files should have borders, remove buttons and be sortable, file_input 
// should be last in chain and have border but not the remove button and not be sortable
// - if user select a file - file input should show remove button and became sortable and there should appear a new file_input - with border
// but without remove button and not be sortabe
// 
Rad.Attachments = new Class({
  initialize: function(element){
    this.element = element;
    
    // initializing attachments
    var _this = this;
    this.element.getElements('.l_item').each(function(attachment){
      attachment.getElement('.l_remove_button').addEvent('click', function(){
        attachment.destroy();
        _this.update();
      });
    });
    
    this.sortables = new Sortables();
    this.addFileField();
    this.update();
  },
  
  addFileField: function(){        
    var template = this.element.getElement('.l_file_field_template').get('value');    
    var fileField = template.toElements();
    fileField.inject(this.element.getElements('.css_clear').last(), 'before');
    fileField.addEvent('change', function(){
      this.addFileField();
      this.update();
    }.bind(this));
    fileField.getElement('.l_remove_button').addEvent('click', function(){
      fileField.destroy();
      this.update();
    }.bind(this));
  },
  
  update: function(){
    var items = this.element.getElements('.l_item');        
    var attachments = items.filter(function(item){
      return !item.getElement('input[type=file]');
    });
    var filledFileInputs = items.filter(function(item){
      var fileInput = item.getElement('input[type=file]');
      return fileInput && !fileInput.get('value').blank();
    });
    var emptyFileInputs = items.filter(function(item){
      var fileInput = item.getElement('input[type=file]');
      return fileInput && fileInput.get('value').blank();
    });    
    
    // clearing all
    this.sortables.detach();
    items.each(function(item){item.getElements('.l_remove_button').hide()});
    items.removeClass('l_item_style').removeClass('l_empty_item_style');
    
    // updating styles
    if(items.size() > 1){
      // displaying filled inputs as attachments
      filledFileInputs.each(function(item){
        var input = item.getElement('input');
        var fname = input.get('value').replace(/^.*(\/|\\)/, '');
        var attachmentStub = item.getElement('.l_attachment_stub');
        
        input.hide();
        attachmentStub.set('text', fname).show();
      });
      
      // 
      var removableAndSortableItems = Array.concat(attachments, filledFileInputs).flatten();
      removableAndSortableItems.each(function(item){
        item.addClass('l_item_style');
        item.getElements('.l_remove_button').show()
      });
      
      emptyFileInputs.addClass('l_empty_item_style')
      this.sortables = new Sortables();
      this.sortables.addItems(removableAndSortableItems);            
    }
  }
});