// 
// rad.assets.require '/vendor/mootools.js'
// 

// 
// Utility functions
// 
var p=function(){
 return console.log.apply(console, arguments);
};

// 
// String extensions
// 
String.implement({
	blank: function(){return this.test(/^\s*$/);},
	size: function(){return this.length;},
	toElements: function(bang){
	  var list;
	  if (this.match(/^\s*</)){
	    list = Elements.from("" + this);
	  }else{
	    list = $$("" + this);
    };
    if(bang && (list.size() == 0)) throw "no elements '" + this + "'!";
    return list;
	},
	toElement: function(bang){
	  var e = this.toElements().first();
	  if(bang && !e) throw "no element '" + this + "'!";
	  return e
	}
});


// 
// Array extensions
// 
Array.implement({
	any: function(){return this.some.apply(this, arguments);},
	add: function(){return this.push.apply(this, arguments);},
	blank: function(){return this.length == 0;},
	size: function(){return this.length;},
	first: function(){return this[0];},
	last: function(){return this[this.length-1];},
	reject: function(fn, bind){return this.filter(function(){return !fn.apply(this, arguments)});},
	none: function(fn, bind){return !this.any.apply(this, arguments);},
	clear: function(){return this.empty.apply(this, arguments);},
});


// 
// Elements
//
Elements.implement({
	applyOnce: function(identifier, fn){this.invoke('applyOnce', identifier, fn);},
  // appendElement: function(obj){this.invoke('append', obj);},
	toElements: function(bang){
	  if(bang && (this.size() == 0)) throw "no elements!";
	  return this;
	},
	toElement: function(bang){
	  if(bang && (this.size() == 0)) throw "no element!";
	  return this.first();
	}
  // last: function(){return this[this.length-1];}
  // show: function(){this.invoke('show');},
  // hide: function(){this.invoke('hide');},
});


// 
// Element extensions
// 
Element.implement({
  getChild: function(){return this.getChildren.apply(this, arguments).first();},
  getElement: function(){return this.getElements.apply(this, arguments).first();},
  // appendElement: function(obj){obj.toElements().inject(this);},
  applyOnce: function(identifier, fn){
		if(!this.retrieve(identifier)){
			fn.apply(this, [this]);
			this.store(identifier, 'initialized');					
		}
	},	
	classNames: function(){
	  return this.className.clean().split(/\s+/);
	},
  toElements: function(bang){return new Elements(this)},
  toElement: function(bang){return this;},
  replaceWith: function(obj){obj.toElements(true).replaces(this);},  
  // append: function(obj){obj.toElements().inject(this)},
	identify: function(){
		var id = this.get('id');
    if(!id){
			var i = 0;
			do { 
	        i++;
	        id = 'auto_id_' + i;
	    } while($(id));            
	    this.set('id', id);
		}            
		return id;
	},
	getData: function(name, value){
		return this.getProperty('data-' + name);
	},
	setData: function(name, value){
		this.setProperty('data-' + name, value);
		return this;
	},
	getInnerSize: function(){
		var dim = this.getComputedSize();
		return {x: dim.width, y: dim.height};
	},
	getOuterSize: function(){
		var dim = this.getComputedSize({styles: ['margin', 'border', 'padding']});
		return {x: dim.totalWidth, y: dim.totalHeight};
	},
	getSpaceSize: function(){
		var dim = this.getComputedSize({styles: ['margin', 'border', 'padding']});
		return {x: dim.computedLeft + dim.computedRight, y: dim.computedTop + dim.computedBottom};
	},
	highlight: function(){
		this.setStyle('border', "5px solid yellow");
	},
	hover: function(fn1,fn2) {
		return this.addEvents({
			mouseenter: function(e) {
				fn1.apply(this, [e]);
			},
			mouseleave: function(e) {
				fn2.apply(this, [e]);
			}
		});
	}
});