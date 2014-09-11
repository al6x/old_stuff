UserScript = function(){
};

UserScript.page_loaded = function(){
    window.uidriver_page_available = true
};

UserScript.ajax_start = function(){
    window.uidriver_page_available = false;
};

UserScript.ajax_finished = function(){
    window.uidriver_page_available = true
}