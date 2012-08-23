// 
// You can attach a Mask to Dialog, and it will acts (show, hide, destroy) automatically.
// 
// dialog = new SimpleDialog()
// SimpleDialog.Mask.new(dialog) // attach and forget about it, it will act automatically
// dialog ...
// 
SimpleDialog.Mask = new Class({
	initialize: function(dialog){	  	      
	  this.element = new Element('div', {'class': 'simple_dialog_mask', styles: {'display': 'none'}});    
    this.element.inject(document.body);
            
    this._attachEvents();
    this._attachToDialog(dialog);
	},
	
	show: function(){
	  this.element.show();
    this._resize();
		this._relocate();
		return this;
	},
	
	hide: function(){
	  this.element.hide();
		return this;
	},
	
	toElement: function (){
	  return this.element;
	},
	
	destroy: function(){	  			
		this._detachEvents();			
		this.element.destroy();
		
		return this;
	},	
	
  // 
  // Protected methods
  // 	
  _attachToDialog: function(dialog){
    ['show', 'hide', 'destroy'].each(function(name){
      dialog.addEvent(name, this[name].bind(this));
    }.bind(this));
  },
  
  _relocate: function(){
    var scrollSize = window.getScroll();
		this.element.setStyles({left: scrollSize.x, top: scrollSize.y});
		return this;
	},
	
	_resize: function(){
    var size = window.getSize();
    this.element.setStyles({width: size.x, height: size.y});
    return this;
	},
	
	_attachEvents: function(){		
	  this.updateEvent = function(e){
	    this._resize();
		  this._relocate();
	  }.bind(this);
	  		
		window.addEvent('resize', this.updateEvent);		
		window.addEvent('scroll', this.updateEvent);
	},
	
	// Detaches events upon close
	_detachEvents: function(){
		window.removeEvent('resize', this.updateEvent);
		window.removeEvent('scroll', this.updateEvent);
	}
});