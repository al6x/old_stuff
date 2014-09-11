UIDriver = function(){
};

// Searches for elements defined by xpath and returns array of founded elements.
UIDriver._list = function(context, xpath){
    var iterator = context.evaluate(xpath, context, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null);
    var i = 0;
    var array = [];
    for (var item = iterator.iterateNext(); item; item = iterator.iterateNext()) {
        array[i] = item;
        i++;
    }
    return array;
}

// Searches for single element defined by xpath
UIDriver._single = function(context, xpath){
    list = UIDriver._list(context, xpath)
    if (list.lenght < 1) 
        throw "Element for '" + xpath + "' XPath not found!";
    if (list.lenght > 1) 
        throw "Found more than one Element for '" + xpath + "' XPath!";
    return list[0]
}

// Absolute position of element e.
UIDriver._absolute_position = function(e){
    var width = e.offsetWidth
    var height = e.offsetHeight
    var x = 0;
    var y = 0;
    if (e.offsetParent) {
        x = e.offsetLeft;
        y = e.offsetTop;
        while (e = e.offsetParent) {
            x += e.offsetLeft;
            y += e.offsetTop;
        }
    }
    //return { x:x, y:y, width:width, height:height };
    return "" + x + "," + y + "," + width + "," + height;
}

// XPath of element
UIDriver._get_element_xpath = function(elt){
    var path = "";
    for (; elt && elt.nodeType == 1; elt = elt.parentNode) {
        var count = 1;
        for (var sib = elt.previousSibling; sib; sib = sib.previousSibling) {
            if (sib.nodeType == 1 && sib.tagName == elt.tagName) 
                count++
        }
        
        var xname = elt.tagName;
        xname += "[" + count + "]";
        path = "/" + xname + path;
    }
    return path;
}

// List of found Element's XPath with Absolute Positions for given XPath
UIDriver.list = function(context, xpath){
    try {
        var list = UIDriver._list(context, xpath);
        var result = "";
        for (var i = 0; i < list.length; i++) {
            var element = list[i];
            var element_xpath = UIDriver._get_element_xpath(element);
            var position = UIDriver._absolute_position(element);
            if (i > 0) 
                result = result + "\n";
            result = result + element_xpath + " : " + position
        }
        return result;
    } 
    catch (error) {
        return "ERROR_MESSAGE" + error;
    }
}

// Evaluates Script in context of Element founded by XPath
UIDriver.xpath_eval = function(context, xpath, code){
    try {
        UIDriver.xpath_eval_element = UIDriver._single(context, xpath)
		code = code.sub(/\$this/, 'UIDriver.xpath_eval_element');
        return eval(code);
    }
    catch (error) {
        return "ERROR_MESSAGE" + error;
    }
}