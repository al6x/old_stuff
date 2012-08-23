// 
// Markup
// 
Rad.Markup = new Class({
  initialize: function(e){
    this.element = e;
    this.allignImagesToLeft();
    this.showImagesInDialog();
  },
  
  // Images by default should be alligned to the left (wrapped inside .left div)
  allignImagesToLeft: function(){
    var images;
    images = this.element.getElements('img');
    // skipping images inside :div's with custom styles
    images = images.reject(function(img){
      var parent;
      parent = img.getParents('div').first();
      return (parent.get('tag') === 'div') && !parent.hasClass('m_markup');
    });
    images.each(function(img){
      // wrapping image with outer link
      img = img.getParent('a') || img;
      (new Element('div.left')).wraps(img);
    });
  },
  
  showImagesInDialog: function(){
    var imageUrls, links, skip_classes;
    skip_classes = ['_nobox', '_video'];

    // selecting links with images
    links = this.element.getElements('a').filter(function(a){
      var child, children;
      children = a.getChildren();
      child = children.first();
      return (children.size() === 1) && (child.get('tag') === 'img') && skip_classes.none(function(cls){return a.hasClass(cls);});
    });
    imageUrls = links.map(function(link){return link.get('href');});
    
    // adding events
    links.each(function(link, i){
      link.addEvent('click', function(event){
        var dialog;
        event.stop();
        dialog = new Rad.ImageDialog({
          images: imageUrls
        });
        dialog.show(imageUrls[i]);
      });
    });
  }
});