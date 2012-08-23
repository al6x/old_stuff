SimpleDialog.Image = new Class({
	Extends: SimpleDialog,

	options: {
	  images: [],
		keys: {
      left: function(){
        var images = this.options.images;
        var i = images.indexOf(this.imageUrl);
        if(i >= 0){
          i = i == 0 ? images.length - 1 : i - 1;
          this.show(images[i]);
        } else {
          console.log("SimpleDialog.Image: can't show previous image!");
        } 
      },
      right: function(){
        var images = this.options.images;
        var i = images.indexOf(this.imageUrl);
        if(i >= 0){
          i = i == images.length - 1 ? 0 : i + 1;
          this.show(images[i]);
        } else {
          console.log("SimpleDialog.Image: can't show next image!");
        }
      },
      esc: function(){
        this.destroy();
      }
    }
	},

	initialize: function(options){
	  this.parent(options);
	},
	

  // 
  // Protected methods
  // 
  _buildContent: function(imageUrl){
	  this.imageUrl = imageUrl;
	  
	  this.image = new Element('img', {
			events: {
				load: function(){
					(function(){
						var setSize = function(){
						  this.image.inject(this.element)
						  this.image.store('dimensions', this.image.getSize()); 
						}.bind(this);
						
						setSize();
						this._resize();
						setSize(); //stupid ie
						this._relocate();						
					}).bind(this).delay(10);
				}.bind(this),
				error: function(){
					this.fireEvent('error');
					this.image.destroy();
					this.element.set('html', this.options.errorMessage);
				}.bind(this)
			},
			styles: {
				width: 'auto',
				height: 'auto'
			}
		});
		this.image.src = imageUrl;
  },
  
  _resize: function(){
    //     //keep currentIndex height/width
    // var currentDimensions = {x: '', y: ''};
    // if(this.image) currentDimensions = this.image.getSize();
    // 
    // ///empty the content, show the indicator
    // this.element.set('html','').setStyles({
    //  width: currentDimensions.x,
    //  height: currentDimensions.y
    // });
    // this._position();
    //     // this.fade();

    var imageDimensions = this.image.retrieve('dimensions');    
    if(imageDimensions){ // check if image already loaded    
      var maxX = (window.getSize().x * 0.9).toInt();
  		var maxY = (window.getSize().y * 0.9).toInt();		
  				
      var imgX = imageDimensions.x; var imgY = imageDimensions.y;
		
      var xRatio = 1, yRatio = 1;
      if(imgX > maxX) xRatio = maxX / imgX;
      if(imgY > maxY) yRatio = maxY / imgY;      
      var ratio = xRatio < yRatio ? xRatio : yRatio;
      
      var imgX = (imgX * ratio).toInt();
      var imgY = (imgY * ratio).toInt();
      
      this.image.width = imgX;
      this.image.height = imgY;    
      this.image.setStyles({width: imgX, height: imgY});      
    }
    

    // 
    // //if image is taller than window...
    //     // if(imageDimensions && (imageDimensions.y > maxHeight)){
    //       // this.image.height = maxHeight;
    //       // this.image.width = (imageDimensions.x * (maxHeight / imageDimensions.y));
    //       // this.image.setStyles({
    //       //  height: maxHeight,
    //       //  width: (imageDimensions.x * (maxHeight / imageDimensions.y)).toInt()
    //       // });
    //     // }
    // 
    // //get rid of styles
    // this.element.setStyles({height: '', width: ''});
	}
});