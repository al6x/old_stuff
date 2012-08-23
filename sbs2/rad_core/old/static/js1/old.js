function Hash(hash) {
	hash = hash || {};
	var _this = this;
	$.each(hash, function(key){_this[key] = this});
};

decode_uri = function(uri){
	return uri.replace(/\&amp;/g,'&');
};


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
	}
});

//
// jQuery Extension
//

$.fn.extend({


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
