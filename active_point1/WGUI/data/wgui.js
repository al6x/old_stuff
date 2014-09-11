var wgui = function(){};
wgui.constants = function(){};
wgui.messages = function(){};

//function loadScript(url)
//{
//    var e = document.createElement("script");
//    e.src = url;
//    e.type="text/javascript";
//    document.getElementsByTagName("head")[0].appendChild(e);
//}
//
//function loadScriptAJAX(surl){
//    dojo.xhrPost({
//        url: surl,
//        handleAs: "text/javascript",
//        load: function(data, args) {
//            try {
//                eval(data)
//            } catch(error) {
//                wgui.show_error(error);
//            }
//        },
//        error: function(response, args) {
//            wgui.show_error(response);
//        }
//    });
//}

wgui.init = function() {
    wgui.start_ajax_push()	
}

// Progress bar start.
wgui.progress_start = function() {
    wgui.progress_start_time = new Date()
    // Progress
    dojo.byId('wgui_progress').style.display = "block";
}

// Progress bar stop. Displays at least 500 msec.
wgui.progress_stop = function() {
    // Progress
    var interval = new Date() - wgui.progress_start_time
    if (interval < 500) {
        setTimeout("dojo.byId('wgui_progress').style.display = \"none\"", 500 - interval)
    } else {
        dojo.byId('wgui_progress').style.display = "none";
    }
}

// Show error.
wgui.show_error = function(message) {
    alert(message)
}

// Copies all needed inputs field to temporary Form and then submits it.
wgui.copy_inputs_to_form = function(inputs, form) {	
	// Copying
    if (!inputs) return false;

    var has_file = false
    for (var i = 0; i < inputs.length; i++) {
        var container = dojo.byId(inputs[i])
		
		// Callbacks
		callbacks = dojo.query(".wgui_before_post", container);
		for(var k = 0; k<callbacks.length; k++){eval(callbacks[k].innerHTML)}
		
        var list = container.getElementsByTagName('*')
        var childs = [container];
        for (var k = 0; k < list.length; k++) childs[k + 1] = list[k];

        for (var j = 0; j < childs.length; j++) {
            var child = childs[j];

            if (child.type == 'text' || child.type == 'textarea') {
                var clone = child.cloneNode(true);
                clone.value = child.value;
                form.appendChild(clone);
            }

            if (child.type == 'radio' || child.type == 'checkbox') {
                var clone = child.cloneNode(true);
                clone.checked = child.checked;
                form.appendChild(clone);
            }

            if (child.type == 'select-one' || child.type == 'select-multiple') {
                var clone = child.cloneNode(true);
                for (var k = 0; k < child.options.length; k++)
                    clone.options[k].selected = child.options[k].selected;
                form.appendChild(clone);
            }

            // We cant just copy 'file' element, because it's forbiden to write to it's 'value' attribute.
            if (child.type == 'file') {
                var clone = window.document.createElement('input');
                clone.type = 'file';
                clone.name = child.name;
                clone.id = child.id

                child.parentNode.replaceChild(clone, child)
                form.appendChild(child);

                has_file = true;
            }
        }
    }
    return has_file
}

// Clear AJAX Form.
wgui.clear_ajax_form = function() {
    var ajax_form = dojo.byId("wgui_ajax_call");
    while (ajax_form.hasChildNodes()) {
        ajax_form.removeChild(ajax_form.firstChild);
    }
    return ajax_form;
}

// AJAX Call.
wgui.ajax_call = function(component_id, action_name, inputs) {
    try {
        if (wgui.active_call) {
            alert(wgui.messages.active_call)
            return
        }
        wgui.active_call = true
        wgui.progress_start()			

        var form = wgui.clear_ajax_form();
        var has_file = wgui.copy_inputs_to_form(inputs, form);

        if (has_file) {
            dojo.io.iframe.send({
                url: wgui.constants.base_uri + "/__iframe_post__/" + component_id + "/" + action_name,
				content: { _sid: wgui.constants.session_id},
                method: "post",
                handleAs: "json",
                handle: function(data, args) {
                    try {
                        wgui.load_responce(data)
                    } catch(error) {
                        wgui.show_error(error)      
                    } finally {
                        try{                
                            wgui.progress_stop()
                            wgui.clear_ajax_form()
                            wgui.active_call = false
                        }catch(error){
                            wgui.show_error(error)
                        }
                    }
                },
                form: dojo.byId('wgui_ajax_call')
            });
        } else {
            dojo.xhrPost({
                url: wgui.constants.base_uri + "/__ajax_post__/" + component_id + "/" + action_name,
				content: { _sid: wgui.constants.session_id},
                handleAs: "json",
                load: function(data, args) {
                    try {
                        wgui.load_responce(data)
                    } catch(error) {
                        wgui.show_error(error)
                    } finally {
                        try{
                            wgui.progress_stop()
                            wgui.clear_ajax_form()
                            wgui.active_call = false
                        }catch(error){
                            wgui.show_error(error)
                        }
                    }
                },
                error: function(response) {
                    try{
                        wgui.progress_stop()
                        wgui.clear_ajax_form()
                        wgui.active_call = false
                        wgui.show_error(response);
                    }catch(error){
                        wgui.show_error(error)
                    }
                },
                form:"wgui_ajax_call"
            });
        }
    } catch(error) {
        wgui.show_error(error);
    }
}

// Asynchronous AJAX process.
wgui.start_ajax_push = function() {
    dojo.xhrPost({
        url: wgui.constants.base_uri + "/__ajax_push__",
        handleAs: "json",
		content: { _sid: wgui.constants.session_id},
        load: function(data, args) {
            try {
                wgui.progress_start()
                wgui.load_responce(data)
                wgui.start_ajax_push()
            } catch(error) {              
                if (error.message == "data has no properties"){
                    wgui.show_error(wgui.messages.broken_connection)
                } else {
//                    wgui.show_error(error)
                }                                
            } finally {
                wgui.progress_stop()
            }
        },
        error: function(response, args) {
            //            wgui.show_error(response);
//            setTimeout("wgui.start_ajax_push()", 5000) // Retry after 5 sec
        }
    });
}

// Loads Server Responce.
wgui.load_responce = function(data) {    
    if (data.error) {
        wgui.show_error(data.error)
    } else if (data.redirect) {
        window.location = data.redirect
    } else if (data.elements) {
        for (var i = 0; i < data.elements.length; i++) {
            var item = data.elements[i]
            var wrapper = window.document.createElement('div');
            wrapper.innerHTML = item.html		

            var new_element = wgui.node_child(wrapper)

            if (!new_element) throw wgui.messages.invalid_ajax_responce

            var old_element = dojo.byId(item.component_id)
            if (!old_element) throw (wgui.messages.old_element_not_found + " ('" + item.component_id + "')")
//            old_element.parentNode.replaceChild(new_element, old_element);						
			
			// Callbacks			
			callbacks = dojo.query(".wgui_before_update", item.component_id);
			for(var k = 0; k<callbacks.length; k++){eval(callbacks[k].innerHTML)}
			
			old_element.innerHTML = new_element.innerHTML			
			scripts = new_element.getElementsByTagName("script")
			for (var k = 0; k < scripts.length; k++){eval(scripts[k].innerHTML)}
        }
    }    
}

// Utility function.
wgui.node_child = function(parent) {
    for (var j = 0; j < parent.childNodes.length; j++) {
        if (parent.childNodes[j].nodeType == 1) {
            return parent.childNodes[j];
        }
    }
}