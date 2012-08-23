//
// Css js hacks (with MooTools)
//

// 
// Support
// 
Element.implement({
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
	}
});
 
 
// 
// Css
// 
Css = new Class({
  initialize: function(){
    this.boxes = {};
    this.styles = {};
  },
  
  box: function(container, options){
    options = options || {};
    options.fixed = Array.from(options.fixed);
    options.managed = Array.from(options.managed);
    this.boxes[container] = this.boxes[container] || [];
    this.boxes[container].push(options)
    return this;
  },
  
  update: function(){
    this.removeClearfixes();
    this.updateBoxes();
    this.addClearfixes();
    this.updateCss();
  },      
  
  add: function(styles){    
    this.styles = Object.merge(this.styles, styles);
    return this;
  },
    
  updateCss: function(){
    var that = this;
    Object.each(this.styles, function(properties, element){
      $$(element).each(function(e){        
        Object.each(properties, function(v, k){          
          that['_' + k](e, v);
        });
      });
    });
    return this;
  },
  
  removeClearfixes: function(){
    $$('._css_clear').destroy();    
  },
  
  addClearfixes: function(){
    $$("*:last-child").filter(function(e){
      return e.getStyle('float') != 'none';
    }).each(function(e){
      this._buildClearer().inject(e, 'after');
    }.bind(this));    
  },
  
  updateBoxes: function(){
    var that = this;
    // selecting containers
    var containers = [];
    var tmpContainerList = [];
    Object.each(this.boxes, function(defs, query){      
      $$(query).each(function(e){
        tmpContainerList.push(e)
        containers.push({container: e, definitions: defs});
      });
    });
    
    // sorting containers (important for nested layout)
    var sortedContainers = [];
    while(containers.length > 0){
      var toDelete = [];
      containers.each(function(meta, i){        
        if(!meta.container.getParents().some(function(parent){return tmpContainerList.contains(parent);})){          
          sortedContainers.push(meta);
          toDelete.push(i);
        }
      });      
      
      toDelete.sort().reverse().each(function(i){
        containers.splice(i, 1);
        tmpContainerList.splice(i, 1);
      });
    };
    
    // laying out
    sortedContainers.each(function(meta){
      var container = meta.container;
      meta.definitions.each(function(def){
        var managed = container.getChildren();                
        
        // skipping not managed elements
        if(def.managed.length != 0){
          managed = managed.filter(function(e){
            return def.managed.some(function(klass){return e.hasClass(klass)});
          });
        };
    
        if(managed.length > 0){
          // sorting managed into fixed and managed.
          var flex = [];
          var fixed = [];
          managed.each(function(e){          
            if (def.fixed.some(function(klass){return e.hasClass(klass);})){
              fixed.push(e);
            } else {
              flex.push(e);
            }
          });
    
          // margin hack: it's important to set float: left before we will measure :margin property, 
          // because otherwise browsers are computed margin-auto differently (some returns 0, some computed value).
          // http://www.3d3r.com/simon/marginAutoComputedValue/
          fixed.invoke('setStyles', {float: 'left', display: 'block'});
          flex.invoke('setStyles', {float: 'left', display: 'block'});
        
          // extra space taken by padding, border, margin
          var takenSpace = 0;
          flex.each(function(e){takenSpace += e.getSpaceSize().x;});
          fixed.each(function(e){takenSpace += e.getOuterSize().x;});
        
          // calculating width of flex items
          var itemWidth = ((container.getInnerSize().x - takenSpace) / flex.length).toInt();
          flex.each(function(e){e.setStyles({width: itemWidth});});
                  
          // adding div:clear at the end          
          var lastManagedElement = managed[managed.length - 1];
          that._buildClearer().inject(lastManagedElement, 'after');
        };
      });
    });    
  },
    
  // 
  // Protected methods
  //
  _buildClearer: function(){
    return new Element('span', {"class": '_css_clear'});
  },
  
  _clear: function(element, position){
    this._buildClearer().inject(element, position);
  },
  
  _autoWidth: function(element, siblings){    
    var parent = element.getParent();
	  var available = parent.getInnerSize().x;	  
	  var taken = element.getSpaceSize().x;	  
	  var children = []
	  parent.getChildren(siblings).each(function(s){
	    children.add(s)
	    taken = taken + s.getOuterSize().x
	  });	  
	  element.setStyle('width', available - taken);
  }
});

css = new Css();