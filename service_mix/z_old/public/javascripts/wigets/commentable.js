// Comments
(function($){
	topics = [];
	var id = 0;
	function nextId(){return id++ };
	
	Commentable = function(params, visual_params){
		this.params = params;
		this.visual_params = visual_params;
		
		this.id = nextId();
		
		topics[this.id] = this;
		
		var _this = this;
		// $(function(){_this.initialize()});
	};
	var _this = Commentable;
	
	_this.render = function(){
		if(topics.size() == 0) return;

		var json_params = {};
		$.each(topics, function(k, v){
			json_params[v.id] = v.params;
		})
		
		sm.ajax(
			'get',
			"/commentable_wiget.json", 
			{json_params: $.toJSON(json_params)}, 
			function(data){_this.renderCallback(data)}
		)
	};
	
	_this.renderCallback = function(data){
		$.each(topics, function(k, t){
			t.renderCallback(data);
		})
	};
		
	Commentable.prototype = {
		initialize: function(){
			var _this = this;
			$(this.visual_params.submit).click(function(){
				var formParams = $(_this.visual_params.form).serializeObject();
				var params = $.extend({}, _this.params, formParams);
				
				sm.ajax(
					'post',
					"/commentable_wiget.json", 
					{json_params: $.toJSON(params)}, 
					function(data){_this.render()}
				)
				return false;
			})
		},
			
		render: function() {
			var json_params = {};
			json_params[this.id] = this.params;

			var _this = this;
			ajax(
				'get',
				"/commentable_wiget.json", 
				{json_params: $.toJSON(json_params)}, 
				function(data){_this.renderCallback(data)}
			)
		},
			
		renderCallback: function(data) {
			var data = data[this.id];
			var p = this.visual_params;
			
			var container = $(p.container);
			container.empty();
			
			if(data.can_view) {
				var t = $.template($(p.comment_template).html());

				$.each(data.comments, function(k, comment){
					container.append(t, comment);
				})
			
				if(data.can_comment){
					container.append($(p.comment_form_template).html());
					this.initialize();
				}else{
					if(p.message_template){
						t = $.template($(p.message_template).html());
						container.append(t, {message: data.cant_comment_cause});
					}
				}
			}
		}
	}
})(jQuery);

$(function(){Commentable.render()});