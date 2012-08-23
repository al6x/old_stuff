// 
// Support AJAX file uploading
// 
Rad.implement({
  submitFormViaIFrame: function(form, data, callback){
    callback = callback || function(){};
    request = new iFrameFormRequest(form, {
      onComplete: function(response){ 
        Browser.exec(response);
        callback.call();
        window.fireEvent('updated');
        window.fireEvent('updateStyle');
      },
      onFailure: function(){
        callback.call();
        console.log("invalid iFrame request!");
        window.fireEvent('updated');
        window.fireEvent('updateStyle');
      }
    }).send();
  },
  
  submitForm: function(form, data, callback){
    var hasFile = form.getElements('input[type=file]').any(function(input){
      return !input.get('value').blank();
    });
    if(hasFile){
      this.submitFormViaIFrame(form, data, callback);
    }else{
      this.submitFormViaXhr(form, data, callback);      
    }
  }
});
