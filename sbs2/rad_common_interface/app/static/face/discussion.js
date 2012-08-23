// 
// Discussion
// 
Rad.Discussion = new Class({
  anew: function(formQ){
    this._buildInplace().edit(formQ);
  },
  create: function(contentQ){
    this._buildInplace().update(contentQ);
  },  
  _buildInplace: function(){
    var inplace = new Rad.AddInplace('.the_discussion .l_comments');
    var control = '.the_discussion .l_controls'.toElements();
    inplace.addEvents({
      edit: control.hide.bind(control),
      update: control.show.bind(control),
      destroy: control.show.bind(control)
    });
    return inplace;
  },
  comment: function(commentQ){
    return new Rad.Comment(this, commentQ);
  }
});


// 
// Comments
// 
Rad.Comment = new Class({
  initialize: function(discussion, commentQ){
    this.discussion = discussion;
    this.comment = commentQ.toElement(true);
  },
  destroy: function(){
    this.comment.destroy();
  },
  update: function(contentQ){
    this._buildInplace().update(contentQ);
  },
  edit: function(formQ){
    this._buildInplace().edit(formQ);
  },
  _buildInplace: function(){
    return new Rad.EditInplace(this.comment);
  },
});