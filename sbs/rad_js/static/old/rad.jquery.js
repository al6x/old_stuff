//  
// Requirements
// 

railsExt = 'defined';

// 
// JavaScript Extension
// 
String.prototype.blank = function() {
	return this.replace(/[\s\n\r]+/, '').length == 0;
};

String.prototype.size = function() {
	return this.length;
};

Array.prototype.size = function() {
	return this.length;
};

function Hash(hash) {
	hash = hash || {};
	var _this = this;
	$.each(hash, function(key){_this[key] = this});
};

Hash.prototype.size = function () {
	var l = -1;
	for (var k in this) {
		l++;
	}
	return l;
};

inspect = function(data){
	console.dir(data);
};

log = function(data){
	console.log(data);
};

p = log;

warn = function(data){
	console.warn(data);
}

decode_uri = function(uri){
	return uri.replace(/\&amp;/g,'&');
};

// 
// jQuery Extension
// 
$.extend({
	infoMessage: function(message){
		log(message);
	},
	
	message: function(msg){
		$.infoMessage(msg)
	},
	
	errorMessage: function(message){
		log(message);
	},
	
	checkForMessages: function(json){
		if(json['info']) $.infoMessage(json['info']);
		if(json['error']) $.errorMessage(json['error']);
	}
});

$.fn.extend({
	serializeObject: function(){
	    var o = {};
	    var a = this.serializeArray();
	    $.each(a, function() {
	        if (o[this.name]) {
	            if (!o[this.name].push) {
	                o[this.name] = [o[this.name]];
	            }
	            o[this.name].push(this.value || '');
	        } else {
	            o[this.name] = this.value || '';
	        }
	    });
	    return o;
	},
	
	identify: function() {
		var id = $(this).attr('id');
    if(!id){
			var i = 0;
			do { 
	        i++;
	        id = 'auto_id_' + i;
	    } while($('#' + id).length > 0);            
	    $(this).attr('id', id);
		}            
		return id;
	},

	first: function(){
		return $((this.size() > 0) ? this[0] : this)
	},
	
	last: function(){
		return $((this.size() > 0) ? this[this.size() - 1] : this)
	},
	
	blank: function(){
		return this.size() < 1
	}
});

// 
// jQuery Template
// 
// try{
// 	$.template.regx.standard = /\#\{([\w-]+)(?:\:([\w\.]*)(?:\((.*?)?\))?)?\}/g;
// }catch(error){
// 	console.info('jquery.template not installed!');
// }

// 
// Initializers
// 
$.extend({
	callOnceForEvery: function(name, query, initializer, dependencyLevel){
		if(!(name && query && initializer)) throw "Invalid arguments!";
		this._addInitializer({name: name, query: query, initializer: initializer}, this._processOnceForEveryInitializer, false, dependencyLevel)
	},
	
	callOnceAfterUpdate: function(name, initializer, dependencyLevel){
		this._addInitializer({name: name, initializer: initializer}, this._processOnceAfterUpdateInitializer, true, dependencyLevel)
	},
	
	callAfterUpdate: function(name, initializer, dependencyLevel){
		this._addInitializer({name: name, initializer: initializer}, this._processAfterUpdateInitializer, false, dependencyLevel)
	},
	
		_orderedInitializers: [[], [], [], [], [], []],
		_addInitializer: function(definition, processor, callOnce, dependencyLevel){
			definition.name = '_' + definition.name + '_initialized';
			dependencyLevel = dependencyLevel || 0;
			if(!(dependencyLevel >= 0 && dependencyLevel <= 5)) throw "Not supported Dependency Level Value: '" + dependencyLevel + "'!";
			this._orderedInitializers[dependencyLevel].push({definition: definition, processor: processor, callOnce: callOnce});
		},
		
		processInitializers: function(){
			for(var i = this._orderedInitializers.size() - 1; i >= 0; i--){
				var initializers = $(this._orderedInitializers[i]);
				var toDelete = [];
				initializers.each(function(i, v){
					// log(v.definition.name);
					v.processor(v.definition);
					if(v.callOnce) toDelete.push(i);
				});
				$(toDelete.reverse()).each(function(){
					initializers.splice(this, this + 1);
				});
			}
		},

		_processOnceForEveryInitializer: function(definition) {
			var count = 0
			$(definition.query).each(function(){
				var e = $(this);
				if(!e.hasClass(definition.name)){ // if(!e.data(definition.name)){
					count = count + 1;
					e.addClass(definition.name); // e.data(definition.name, true);
					definition.initializer.apply($(this));
				}
			});
			// log(definition.name + ', ' + definition.query + ': ' + $(definition.query).size() + '/' + count)
		},
	
		_processOnceAfterUpdateInitializer: function(definition){
			definition.initializer();
		},
		
		_processAfterUpdateInitializer: function(definition){
			definition.initializer();
		}
});

$(function(){
	$.processInitializers();
});
$(document).ajaxSuccess(function(){
	$.processInitializers();
});


// 
// AJAX
// 
$.ajaxSetup({
  authenticity_token: $.authenticity_token,
  type: "script",
	dataType: "script",
	format: 'js'
});


// 
// dataAttr
// 
$.fn.extend({
	dataAttr: function(name, value) {
		var attr_name = 'data-' + name;
		if(value){
			this.attr(attr_name, value);
		}else{
			return this.attr(attr_name);
		}
	}
});


// 
// link_to
// 
$.fn.extend({
	link_to: function(options) {
		options = $.extend({url: $(this).attr('href'), method: 'get'}, options);
		options.method = options.method.toLowerCase();
		// if(options.method == 'put' || options.method == 'delete') options.method = 'post';
		try{
			if(options.ajax){
				var data = {
					_method: options.method,
					target: $(this).identify()
				};
				if(options.method != 'get') data.authenticity_token = $.authenticity_token;
				$.ajax({
					data: $.param(data), 
					dataType: 'script', 
					type: options.method, 
					url: options.url
				});
			}else{
				var url = $(this).attr('href');
				var form = $("<form method='POST'>").attr("action", options.url);
				var params = {'authenticity_token': $.authenticity_token, '_method': options.method}
		    $.each(params, function(name, value) {
					$("<input type='hidden'>").attr("name", name).attr("value", value).appendTo(form);
		    });
		    form.appendTo("body");
		    form.submit();
			}
		}catch(e){console.log(e)};
	}
});
// it doesn't works
// $(document).ajaxError(function (e, r, o, e) {
//   console.log(e);
// });


// 
// Helpers
// 
// AJAX for autosubmitting changes
$.callOnceForEvery('autosubmit', '._autosubmit_on_change', function() {	
	var e = $(this);
	e.bind('change', function(){
		$.post(e.dataAttr('action'), {value: e.val(), target: e.identify()})
	});
});
