// 
// More
// 
Rad.More = new Class({
  initialize: function(element){    
    this.element = element;
    var id = this.element.getData('id');
    this.core = $(id + '_core');    
    this.more = $(id + '_more');
    
    if(!this.more) console.log("Rad.More: no content for '" + id + "'!"); 
    
    // add event to button
    element.addEvent('click', function(event){
      event.stop();
      Rad.More.opened_containers[id] = true;      
      this._show();
    }.bind(this));
    
    // if opened once, keep it open in all next ajax updates
    if(Rad.More.opened_containers[id]) this._show();
  },
  _show: function(){    
    this.more.getChildren().reverse().each(function(e){
      e.inject(this.element, 'after');
    }.bind(this));
    if(this.core) this.core.destroy();
    this.more.destroy();
    this.element.destroy();
    window.fireEvent('updateStyle');
  }
});
Rad.More.opened_containers = {};