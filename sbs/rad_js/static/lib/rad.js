// 
// rad.assets.require '/lib/mootools.extensions.js'
// 


Rad = new Class({
  initialize: function(){
    this.deferred = [];
  },
  defer: function(fn){
    this.deferred.push(fn);
  },
  callDeferred: function(){
    this.deferred.each(function(fn){fn()});
    this.deferred = [];
  }
});

// 
// Request
// 
Rad.Request = new Class({
  Extends: Request,

  options: {
    method: 'post',
    evalScripts: true,
    evalResponse: true   
    // data: {authenticity_token: window.AUTHENTICITY_TOKEN},
  },  
  
  initialize: function(options){
    // adding authenticity_token
    if(options.method != 'get'){
      if(typeOf(options.data) == 'object') options.data.authenticity_token = window.AUTHENTICITY_TOKEN;          
      else if (typeOf(options.data) == 'string') {
        options.data = options.data + "&authenticity_token=" + encodeURIComponent(window.AUTHENTICITY_TOKEN);
      } else options.data = "authenticity_token=" + window.AUTHENTICITY_TOKEN;
    }
    this.parent(options);
	},
  
  success: function(text, xml){   
    try{
      this.fireEvent('load', arguments);
      this.parent(text, xml);
    }catch(e){console.log(e)};
    window.fireEvent('updated');
    window.fireEvent('updateStyle');
  },
  
  failure: function(){
    this.parent();
    console.log('Rad.Request failed!');
    window.fireEvent('updated');
    window.fireEvent('updateStyle');
  }
});
 

// 
// Rad
// 
Rad.implement({
  call: function(url, data, options){
    options = options || {};
    options.url = url;
    if (data._method) options.method = data._method;
    options.data = Object.merge({}, options.data, data);    
    var request = new Rad.Request(options);
    request.send();
  },

  submitFormViaXhr: function(form, data, callback){
    callback = callback || function(){};
    var url = form.get('action');
    
    var stringData = form.toQueryString();
    if(data) stringData = stringData + '&' + Object.toQueryString(data);

    options = {
      url: url, 
      data: stringData,
      onLoad: callback
    };

    var request = new Rad.Request(options);
    request.send();
  },
    
  process_js_link: function(event){
    var target = event.target;
    
    // some element shouldn't be autosubmitted as soon as You click on it, selets for example
    if(Rad.not_js_links.contains(target.get('tag'))) return;
    
    var confirmMessage = target.getProperty('data-confirm');
    if(confirmMessage && !confirm(confirmMessage)){
      event.stop();
      return;
    };    
    
    var action = target.getProperty('data-action');
    if(action){
      event.stop();    
    
      var method = target.getProperty('data-method') || 'post';
      var remote = target.getProperty('data-remote');
      var target_id = target.identify && target.identify();

      if(remote){
        rad.call(action, {_method: method, _target: target_id});
      }else{    
        var form = new Element('form', {method: 'post', action: action});
        var params = {'authenticity_token': window.AUTHENTICITY_TOKEN, '_method': options.method};
        params.each(function(name, value){
          var input = new Element('input', {type: 'hidden', name: name, value: value});
          input.inject(form);
        });
        document.body.inject(form);
        form.submit();
      }
    };
  }  
});
Rad.not_js_links = ['select']
Rad.implement({
  submitForm: Rad.prototype.submitFormViaXhr
});

rad = new Rad();


// 
// JavaScript links
// 
window.addEvent('domready', function(){
  document.body.addEvent('click', function(event){
    rad.process_js_link(event);    
  });
});

// 
// Events
// 
window.addEvent('domready', function(){ 
  window.fireEvent('updated');
  window.fireEvent('updateStyle');
});
window.addEvent('resize', function(){
  window.fireEvent('updateStyle');
});