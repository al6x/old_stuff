// Vote
(function($){
	var votes = [];
	var id = 0;
	function nextId(){return id++ }
	
	Votable = function(params, visual_params){
		this.params = params;
		this.visual_params = visual_params;
		
		this.id = nextId();
		
		votes[this.id] = this;
		
		var _this = this;
		$(function(){_this.initialize()});
	};
	var _this = Votable;
	
	_this.render = function(){
		if(votes.size() == 0) return;

		var json_params = {};
		$.each(votes, function(k, v){
			json_params[v.id] = v.params;
		})
		
		ajax(
			'get',
			"/votable_wiget.json", 
			{json_params: $.toJSON(json_params)}, 
			function(data){_this.renderCallback(data)}
		)
	};
	
	_this.renderCallback = function(data){
		$.each(votes, function(k, v){
			v.renderCallback(data);
		})
	};
		
	Votable.prototype = {
		initialize: function(){
			var _this = this;
			$(this.visual_params.control).click(function(){
				sm.ajax(
					'post',
					"/votable_wiget.js", 
					{json_params: $.toJSON(_this.params)}, 
					function(data){_this.render()}
				)
				return false;
			})
		},
			
		render: function() {
			// param[this.id] = this.secure_params 
			var json_params = {};
			json_params[this.id] = this.params;

			var _this = this;
			ajax(
				'get',
				"/votable_wiget.json", 
				{json_params: $.toJSON(json_params)}, 
				function(data){_this.renderCallback(data)}
			)
		},
			
		renderCallback: function(data) {
			var data = data[this.id];
			
			var p = this.visual_params;
			$.each(p, function(key, value){$(value).hide()});
			
			if(data.can_view) {
				if(p.rating) $(p.rating).text(data.rating).show();
				if(p.rating_word) $(p.rating_word).text(data.rating_word).show();
			
				if(data.can_vote) {
					if(p.control) $(p.control).show();
				} else {
					if(p.cant_vote_cause) $(p.cant_vote_cause).text(data.cant_vote_cause).show();
				}
			}
		}
	}
})(jQuery);

$(function(){Votable.render()});