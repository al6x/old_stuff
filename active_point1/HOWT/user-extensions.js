// ========== Utility functions ==========
// Utility function searches for elements defined by xpath and returns array of founded elements.
Selenium.prototype.xpath_search = function(context, xpath) {
    var iterator = context.evaluate(xpath, context, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null);
    var i = 0;
    var array = [];
    for (var item = iterator.iterateNext(); item; item = iterator.iterateNext()) {
        array[i] = item;
        i++;
    }
    return array;
}

// Exact or RegExp match
Selenium.prototype.match = function(text, word, regexp) {
    if (regexp) {
        return "contains(" + text + ", \"" + word + "\")";
    } else {
        return text + " = \"" + word + "\"";
    }
}

// List of specified [button, link, textfield, textarea, select, radiobutton, checkbox, file, text, any]
// controls wich contains 'text'
Selenium.prototype.list_of_elements = function(context, text, re, types) {
    match = Selenium.prototype.match;
    var all_types_with_text = {
        button : "//input[" + match("@value", text, re) + " and (@type = 'button' or @type = 'submit')]|" +
                 "//button[" + match("@value", text, re) + " or " + match("text()", text, re) + "]",
        link : "//a[" + match("text()", text, re) + "]",

        textfield : "//input[" + match("@value", text, re) + " and @type = 'text']",
        textarea : "//textarea[" + match("text()", text, re) + "]",
        select : "//select/option[" + match("text()", text, re) + "]/..",
        //        radiobutton
        //        checkbox
        //        file

        text : "//*[" + match("text()", text, re) + " and name(.) != 'TEXTAREA' and name(.) != 'BUTTON']",

        // WARNING! It doesn't works with '@*' expression (probably some internal Selenium's bug ...)
        // so i used to use '@value'
        any : "//*[" + match("@value", text, re) + " or " + match("text()", text, re) + "]"
    }

    var all_types_without_text = {
        button : "//input[@type = 'button' or @type = 'submit']",
        link : "//a",

        textfield : "//input[@type = 'text']",
        textarea : "//textarea",
        select : "//select",
        radiobutton : "//input[@type = 'radio']",
        checkbox : "//input[@type = 'checkbox']",
        file : "//input[@type = 'file']"

        //        text

        //        any
    }

    var avaliable_types;
    if (text) {
        avaliable_types = all_types_with_text;
    } else {
        avaliable_types = all_types_without_text;
    }

    var result = [];
    for (var i = 0; i < types.length; i++) {
        var xpath = avaliable_types[types[i]];
        if (xpath) {
            result = result.concat(Selenium.prototype.xpath_search(context, xpath));
        } else {
            throw "Unsupported Element Type '" + types[i] + "'!";
        }
    }
    return result;
}

// Utility function. Absolute position of element e.
Selenium.prototype.absolute_position = function(e) {
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
    return { x:x, y:y, width:width, height:height };
}

// XPath of element
Selenium.prototype.get_element_xpath = function(elt)
{
    var path = "";
    for (; elt && elt.nodeType == 1; elt = elt.parentNode)
    {
        var count = 1;
        for (var sib = elt.previousSibling; sib; sib = sib.previousSibling)
        {
            if (sib.nodeType == 1 && sib.tagName == elt.tagName) count++
        }

        var xname = elt.tagName;
        xname += "[" + count + "]";
        path = "/" + xname + path;
    }
    return path;
}

// Utility function, calculates scope coordinates
Selenium.prototype.calculate_scope = function(context, scope_def) {
    // Find positions of elements.
    var positions = [];
    for (var i = 0; i < 4; i++) {
        var meta = scope_def[i]
        if (meta.length > 0) {
            var list = Selenium.prototype.list_of_elements(context, meta[0], meta[1], meta[2]);
            if (list.length == 0) {
                throw "There is no ['" + meta[2] + "'] with text '" + meta[0] + "'!";
            }
            if (list.length > 1) {
                throw "Found more than one elements '" + meta[1] + "' with text '" + meta[0] + "'!";
            }
            positions[i] = Selenium.prototype.absolute_position(list[0]);
        } else {
            positions[i] = null;
        }
    }

    // Calculating positions of area.
    scope = {left : null, right : null, top : null, bottom : null};
    if (positions[0]) scope.left = positions[0].x;
    if (positions[1]) scope.right = positions[1].x + positions[1].width
    if (positions[2]) scope.top = positions[2].y
    if (positions[3]) scope.bottom = positions[3].y + positions[3].height
    return scope;
}

// Utitity function, filters result so that they are in scope.
Selenium.prototype.filter_by_scope = function(list, scope)
{
    var result = [];
    var j = 0;
    for (var i = 0; i < list.length; i++) {
        var e = Selenium.prototype.absolute_position(list[i]);

        if (scope.left && (e.x < scope.left)) continue;
        if (scope.right && (e.x + e.width > scope.right)) continue;
        if (scope.top && (e.y < scope.top)) continue;
        if (scope.bottom && (e.y + e.height > scope.bottom)) continue;

        result[j] = list[i];
        j++;
    }
    return result;
}

//// ========== fuzzy_search ==========
// Calculates distance between text_element element and list of controls and returns distances as array
// metric - nearest, left, top, right, bottom - type of metric
Selenium.prototype.find_nearest = function(text_element, controls, metric) {
    if (controls.length < 1) {
        throw "Controls list is empty, should be one or more controls!";
    }
    var x1, y1;
    var x2 = [];
    var y2 = [];
    var ta = Selenium.prototype.absolute_position(text_element);
    var ca, i;
    // Defining (x1, y1) and (x2, y2)
    if (metric == "nearest_to") {
        x1 = ta.x + ta.width / 2.0;
        y1 = ta.y + ta.height / 2.0;
        for (i = 0; i < controls.length; i++) {
            ca = Selenium.prototype.absolute_position(controls[i]);
            x2[i] = ca.x + ca.width / 2.0;
            y2[i] = ca.y + ca.height / 2.0;
        }
    } else if (metric == "from_left_of") {
        x1 = ta.x;
        y1 = ta.y + ta.height / 2.0;
        for (i = 0; i < controls.length; i++) {
            ca = Selenium.prototype.absolute_position(controls[i]);
            x2[i] = ca.x + ca.width;
            y2[i] = ca.y + ca.height / 2.0;
        }
    } else if (metric == "from_right_of") {
        x1 = ta.x + ta.width;
        y1 = ta.y + ta.height / 2.0;
        for (i = 0; i < controls.length; i++) {
            ca = Selenium.prototype.absolute_position(controls[i]);
            x2[i] = ca.x;
            y2[i] = ca.y + ca.height / 2.0;
        }
    } else if (metric == "from_top_of") {
        x1 = ta.x + ta.width / 2.0;
        y1 = ta.y;
        for (i = 0; i < controls.length; i++) {
            ca = Selenium.prototype.absolute_position(controls[i]);
            x2[i] = ca.x + ca.width / 2.0;
            y2[i] = ca.y + ca.height;
        }
    } else if (metric == "from_bottom_of") {
        x1 = ta.x + ta.width / 2.0;
        y1 = ta.y + ta.height;
        for (i = 0; i < controls.length; i++) {
            ca = Selenium.prototype.absolute_position(controls[i]);
            x2[i] = ca.x + ca.width / 2.0;
            y2[i] = ca.y;
        }
    } else {
        throw "Unsupported metric '" + metric + "'!";
    }

    // Evaluating minimal distance between p1 i p2
    var min = Math.sqrt(Math.pow((x1 - x2[0]), 2) + Math.pow((y1 - y2[0]), 2));
    var nearest_control = controls[0];
    var distance;
    for (i = 1; i < x2.length; i++) {
        distance = Math.sqrt(Math.pow((x1 - x2[i]), 2) + Math.pow((y1 - y2[i]), 2));
        if (distance < min) {
            min = distance;
            nearest_control = controls[i];
        }
    }
    return nearest_control;
}

// Fuzzy search
Selenium.prototype.fuzzy_search = function(context, text, text_re, metric, control_text, control_text_re, text_types, control_types, scope_def) {
    try {
        var scope = Selenium.prototype.calculate_scope(context, scope_def);

        var text_elements = Selenium.prototype.list_of_elements(context, text, text_re, text_types);
        text_elements = Selenium.prototype.filter_by_scope(text_elements, scope);
        if (text_elements.length == 0) {
            throw "There is no Text Element with '" + text + "'!";
        }
        if (text_elements.length > 1) {
            throw "Found more than one Text Elements with '" + text + "'!";
        }

        var controls = Selenium.prototype.list_of_elements(context, control_text, control_text_re, control_types);
        controls = Selenium.prototype.filter_by_scope(controls, scope);
        if (controls.length < 1) {
            throw "Can't find Controls with '" + text + "' of type [" + control_types + "]!";
        }
        var nearest_control = Selenium.prototype.find_nearest(text_elements[0], controls, metric);
        return Selenium.prototype.get_element_xpath(nearest_control);
    } catch(error) {
        return "ERROR_MESSAGE" + error;
    }
}

// ========== count_of_elements ==========
Selenium.prototype.count_of_elements = function(context, text, re, types, scope_def) {
    try {
        var list = Selenium.prototype.list_of_elements(context, text, re, types);
        var scope = Selenium.prototype.calculate_scope(context, scope_def);
        list = Selenium.prototype.filter_by_scope(list, scope);
        //var list = Selenium.prototype.xpath_search(context, '//*[contains(@value, "'+text+'") or contains(text(), "'+text+'")]')
        return list.length;
    } catch(error) {
        return "ERROR_MESSAGE" + error;
    }
}

// ========== element_search ==========
Selenium.prototype.element_search = function(context, text, re, types, scope_def) {
    try {
        var elements = Selenium.prototype.list_of_elements(context, text, re, types);
        var scope = Selenium.prototype.calculate_scope(context, scope_def);
        elements = Selenium.prototype.filter_by_scope(elements, scope);
        if (elements.length == 0) {
            throw "There is no [" + types + "] Element with '" + text + "'!";
        }
        if (elements.length > 1) {
            throw "Found more than one [" + types + "] Elements with '" + text + "'!";
        }

        return Selenium.prototype.get_element_xpath(elements[0]);
    } catch(error) {
        return "ERROR_MESSAGE" + error;
    }
}