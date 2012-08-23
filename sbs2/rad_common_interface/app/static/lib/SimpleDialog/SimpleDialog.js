var SimpleDialog = new Class({
	Implements: [Options, Events],
	
	options: {
		keys:{
			esc: function(){this.destroy();}
		}
	},
	
	initialize: function(options){
		this.setOptions(options);
    this._buildElement();
    this._attachKeyEvents();
    this._attachUpdateEvents();
		this._setFocus();
	},
	
	show: function(){
	  this.element.empty();
	  this._buildContent.apply(this, arguments);
	  
	  this.element.show();
    this._resize();
		this._relocate();
		
		this.fireEvent('show');
		
		return this;
	},
	
	hide: function(){
	  this.element.hide();
	  this.fireEvent('hide');
		return this;
	},	
	
	destroy: function(){	  
		this.fireEvent('destroy');			
		this._detachEvents();			
		this.element.destroy();
		return this;
	},
	
	wait: function(content){
	  content = content || "<p>Please wait ...</p>"
	  this.element.getChildren().hide();
	  Elements.from(content).inject(this.element);
	  return this;
	},
	
	toElement: function (){
		return this.element;
	},
		
  // 
  // Protected methods
  // 	
  _relocate: function(){
    var windowSize = window.getSize(), 
			scrollSize = window.getScroll(), 
			elementSize = this.element.getSize();
		this.element.setStyles({
			left: scrollSize.x + ((windowSize.x - elementSize.x) / 2),
			top: scrollSize.y + ((windowSize.y - elementSize.y) / 3)
		});
		return this;		    
	},
	
	_resize: function(){
	},
  
  _buildElement: function(){
	  this.element = new Element('div', {'class': 'simple_dialog', styles: {'display': 'none'}});    
	  this.element.inject(document.body);
	},
	
	_buildContent: function(html){
	  Elements.from(html).inject(this.element);
	},
  
	_setFocus: function(){
	  (function(){
	    this.element.setAttribute('tabIndex',0);
  		this.element.focus();
	  }).bind(this).delay(10);	      
	},
		
	_attachKeyEvents: function(){
	  this.keyEvent = function(e){
			if(this.options.keys[e.key]) this.options.keys[e.key].call(this);
		}.bind(this);
		this.element.addEvent('keyup', this.keyEvent);
	},
	
	_attachUpdateEvents: function(){
		this.updateEvent = function(e){
		  this._resize();
		  this._relocate();
		}.bind(this);		
		window.addEvent('resize', this.updateEvent);		
		window.addEvent('scroll', this.updateEvent);
		window.addEvent('updateStyle', this.updateEvent);
	},
	
	_detachEvents: function(){
		if(this.keyEvent) this.element.removeEvent('keyup', this.keyEvent);
		if(this.updateEvent){ 
  		window.removeEvent('resize', this.updateEvent);
  		window.removeEvent('scroll', this.updateEvent);
  		window.removeEvent('updateStyle', this.updateEvent);
  	}
	}
});


// 
// Autodestroy - closes element if user clicks on element or anywhere on the document body.
// 
SimpleDialog.Autodestroy = new Class({
  autodestroy: function(){
    SimpleDialog.Autodestroy.elements.add(this);
    this.addEvent('click', function(){
      this.close();
    }.bind(this));
  }
});
      
SimpleDialog.Autodestroy.extend({
  elements: [],
  close: function(){
    this.elements.invoke('destroy');
    this.elements.clear();
    
  }
});  

document.body.addEvent('click', function(){
  SimpleDialog.Autodestroy.close();
});


// 
// OnlyOne, allows only one instance of element to be active, closes all other elements when a new one is created.
// 
SimpleDialog.OnlyOne = new Class({
  onlyOne: function(element){
    SimpleDialog.OnlyOne.onlyOne(element);
  }
});

SimpleDialog.OnlyOne.extend({
  elements: [],
  onlyOne: function(element){
    this.elements.invoke('destroy');
    this.elements.clear();
    this.elements.add(element);
  }
});