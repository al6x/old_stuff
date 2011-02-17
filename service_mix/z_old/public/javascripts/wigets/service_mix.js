// Requirements
railsExt;

// ServiceMix
(function($){
	
	SM = function(base_params, flash_params){
		this.base_params = base_params;
		this.flash_params = flash_params;
	}
	
	SM.prototype = {
		serviceUrl: function(path){
			return "/sm" + path;
		},
				
		ajax: function(type, url, params, callback){
			var params = $.extend({_method: type}, sm.base_params, params);
			$.ajax({
				type: 'post',
				url: sm.serviceUrl(url),
				data: params,
				success: function(data){
					$.checkForMessages(data)
					if(!data.error) callback(data);
				},
				error: function(){
					$.errorMessage('Service Mix Failure')
				},
				dataType: "json"
			});
		}
	}
})(jQuery);