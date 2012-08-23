(function() {
  var Mary, getValue, method, methods, name, type, types, wrapper, _i, _len,
    __slice = Array.prototype.slice,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  if (typeof jasmine === "undefined" || jasmine === null) {
    throw new Error("no jasmine (mary requires jasmine BDD framework)!");
  }

  jasmine.Matchers.prototype.toInclude = function(expected) {
    if (this.actual.indexOf) {
      return this.actual.indexOf(expected) >= 0;
    } else {
      return expected in this.actual;
    }
  };

  jasmine.Matchers.prototype.toInclude = jasmine.Matchers.matcherFn_('toInclude', jasmine.Matchers.prototype.toInclude);

  Mary = {};

  Mary.Matcher = (function() {

    function Matcher(obj) {
      this.obj = obj;
      this.expect = expect(obj);
    }

    Matcher.prototype.include = function(o) {
      return this.expect.toInclude(o);
    };

    Matcher.prototype.beEqualTo = function(o) {
      return this.expect.toEqual(o);
    };

    Matcher.prototype.be = function(o) {
      return this.expect.toEqual(o);
    };

    Matcher.prototype.match = function(o) {
      return this.expect.toMatch(o);
    };

    Matcher.prototype.contain = function(o) {
      return this.expect.toContain(o);
    };

    Matcher.prototype.beLessThan = function(o) {
      return this.expect.toBeLessThan(o);
    };

    Matcher.prototype.beGreaterThan = function(o) {
      return this.expect.toBeGreaterThan(o);
    };

    Matcher.prototype["throw"] = function(o) {
      return this.expect.toThrow(o);
    };

    Matcher.prototype.raise = function(o) {
      return this.expect.toThrow(o);
    };

    Matcher.prototype.beNull = function() {
      return this.expect.toBeNull();
    };

    Matcher.prototype.beTrue = function() {
      return this.expect.toBeTruthy();
    };

    Matcher.prototype.beFalse = function() {
      return this.expect.toBeFalsy();
    };

    Matcher.prototype.beDefined = function() {
      return this.expect.toBeDefined();
    };

    Matcher.prototype.beUndefined = function() {
      return this.expect.toBeUndefined();
    };

    Matcher.prototype.haveBeenCalled = function() {
      return this.expect.toHaveBeenCalled();
    };

    Matcher.prototype.haveBeenCalledWith = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.expect.toHaveBeenCalledWith.apply(this.expect, args);
    };

    Matcher.prototype.applyHashMatchers = function(args) {
      var matcher, value;
      if (args) {
        for (matcher in args) {
          value = args[matcher];
          this[matcher](value);
        }
      }
      return this;
    };

    return Matcher;

  })();

  Mary.NegativeMatcher = (function(_super) {

    __extends(NegativeMatcher, _super);

    function NegativeMatcher(obj) {
      this.obj = obj;
      this.expect = expect(obj).not;
    }

    return NegativeMatcher;

  })(Mary.Matcher);

  getValue = function(obj) {
    if (obj.hasOwnProperty('_wrapped')) {
      return obj._wrapped;
    } else {
      return obj.valueOf();
    }
  };

  methods = {
    should: function(args) {
      return new Mary.Matcher(getValue(this)).applyHashMatchers(args);
    },
    shouldNot: function(args) {
      return new Mary.NegativeMatcher(getValue(this)).applyHashMatchers(args);
    },
    spyOn: function(method, options) {
      var arg, spy;
      spy = spyOn(getValue(this), method);
      if (options) {
        for (method in options) {
          arg = options[method];
          spy[method](arg);
        }
      }
      return spy;
    }
  };

  types = [Object.prototype, String.prototype, Number.prototype, Array.prototype, Boolean.prototype, Date.prototype, Function.prototype, RegExp.prototype];

  for (_i = 0, _len = types.length; _i < _len; _i++) {
    type = types[_i];
    for (name in methods) {
      method = methods[name];
      Object.defineProperty(type, name, {
        enumerable: false,
        writable: true,
        configurable: true,
        value: method
      });
    }
  }

  wrapper = function(obj) {
    wrapper = new Object();
    wrapper._wrapped = obj;
    return wrapper;
  };

  it.async = function(desc, func) {
    return it(desc, function() {
      it.finished = false;
      func();
      return waitsFor((function() {
        return it.finished;
      }), desc, 1000);
    });
  };

  it.next = function(e) {
    it.lastError = e;
    return it.finished = true;
  };

  it.sync = function(desc, callback) {
    try {
      require('fibers');
    } catch (e) {
      console.log("WARN:\n  You are trying to use synchronous mode.\n  Synchronous mode is optional and requires additional `fibers` library.\n  It seems that there's no such library in Your system.\n  Please install it with `npm install fibers`.");
      throw e;
    }
    return it.async(desc, function() {
      return Fiber(function() {
        callback();
        return it.next();
      }).run();
    });
  };

  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    exports.Mary = Mary;
    exports._ = wrapper;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Mary = Mary;
    window._ || (window._ = wrapper);
  }

}).call(this);
