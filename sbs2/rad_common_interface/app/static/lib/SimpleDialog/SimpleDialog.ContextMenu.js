SimpleDialog.ContextMenu = new Class({
  Extends: SimpleDialog,
  
  show: function(x, y, html){
    this.x = x;
    this.y = y;
    this.parent(html); 
  },
  
  // 
  // Protected
  // 
  _relocate: function(){
    // var target_x = this.event.page.x; // this.target.getPosition().x + this.target.getOuterSize().x / 2;
    // var target_y = this.event.page.y; // this.target.getPosition().y + this.target.getOuterSize().y / 2;  
  
    var border_bottom = window.getScroll().y + window.getSize().y;
    var border_right = window.getSize().x // $$('.layout_content').first().getInnerSize().x
  
    var offset = 0;
    var psize = this.element.getOuterSize();
    if((border_right - (offset * 2)) >= (this.x + psize.x)){
      x = this.x + offset;
    } else {
      x = border_right - psize.x - (offset * 3);
    }
    
    if((border_bottom + (offset * 2)) >= (this.y + psize.y)){
      y = this.y + offset;
    } else {
      y = this.y - psize.y - offset;
    }
  
    this.element.setStyles({left: x, top: y});
  }
});  