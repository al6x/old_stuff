// 
// Tabs
// 
Rad.Tabs = new Class({
  initialize: function(tabsQ){
    this.element = tabsQ.toElement(true);
    var tabs = this.element.getElements('> .l_panel .l_item');
    var contents = this.element.getElements('> .l_content .l_item');
    tabs.each(function(tab){
      var link = tab.getChild('a');
      if(link && link.getData('content_id')){
        link.addEvent('click', function(event){
          event.stop();
          var tab = this.getParent('.l_item');
          tabs.each(function(e){
            e == tab ? e.addClass('l_active') : e.removeClass('l_active');
          });
          contents.each(function(e){
            e.get('id') == this.getData('content_id') ? e.show() : e.hide();
          }.bind(this));            
          window.fireEvent('updateStyle');
        });
      };
    });
  }
});