###
CoffeeScript / JavaScript Standard Library.

1. Injecting Underscore.js methods into Native Objects.
2. Custom language extensions.

rad.require '/vendor/underscore.js'
###

_ = require 'underscore' if require?

# Extends object without making properties enumerable.
Object.defineProperty Object.prototype, 'extendWithoutEnumeration',
  enumerable: false
  writable: true
  configurable: true
  value: (attrs) ->
    _.each attrs, (v, k) =>
      Object.defineProperty @, k,
        enumerable: false,
        writable: true,
        configurable: true,
        value: v

# ### Extending Natives with Underscore.js methods.

# Helper for injecting Underscore.js methods into Natives.
extendWithUnderscore = (object, names) ->
  methods = {}
  _.each names, (name) ->
    methods[name] = (args...) ->
      _[name].apply(_, [@].concat(_.toArray(arguments)))
  object.extendWithoutEnumeration methods

# Array.
extendWithUnderscore Array.prototype, [
  'each', 'map', 'reduce', 'reduceRight', 'detect', 'select',
  'reject', 'all', 'any', 'include', 'invoke', 'pluck', 'max', 'min', 'sortBy', 'groupBy',
  'sortedIndex', 'size',

  'first', 'rest', 'last', 'compact', 'flatten', 'without', 'union', 'intersection',
  'difference', 'uniq', 'zip', 'indexOf', 'lastIndexOf', 'range',

  'isEmpty',

  'filter', 'every', 'some'
]

# Function.
extendWithUnderscore Function.prototype, [
  'bind', 'bindAll', 'memoize', 'delay', 'defer', 'throttle', 'debounce', 'once', 'after', 'wrap', 'compose'
]

# Object.
extendWithUnderscore Object.prototype, [
  'keys', 'values', 'functions', 'extend', 'clone', 'tap', 'each', 'size'
]

# Adding these Underscore.js methods may cause problems, so I don't inject it into natives.
#
# 'defaults',
# 'isEqual', 'isEmpty', 'isElement', 'isArray', 'isArguments', 'isFunction', 'isString', 'isNumber',
# 'isBoolean', 'isDate', 'isRegExp', 'isNaN', 'isNull', 'isUndefined'

# Small addition to Underscore.js
_.valueOf = (o, args...) ->
  if _.isFunction(o)
    o(args...)
  else if o and o.valueOf
    o.valueOf()
  else
    o

_.templateSettings = {
  evaluate    : /<%([\s\S]+?)%>/g,
  escape      : /<%=([\s\S]+?)%>/g
  interpolate : /<%-([\s\S]+?)%>/g
}

Object.prototype.extendWithoutEnumeration
  # TODO2 delete it?
  toArray2: ->
    array = []
    @each (v, k) -> array.push([k, v])
    array

# ### Custom language extensions.
#
# set `skip_custom_language_extensions` to true to skip it.
unless skip_custom_language_extensions?

  # Function.
  _tempConstructor = ->
  Function.prototype.extendWithoutEnumeration
    # Syntaxic sugar, new method - `obj = Obj.new()` instead of `obj = new Obj()`.
    new: ->
      _tempConstructor.prototype = @prototype
      instance = new _tempConstructor()
      this.apply instance, arguments
      instance

  # Object.
  Object.prototype.extendWithoutEnumeration
    # Syntaxic sugar, deleteProperty method - `obj.deleteProperty 'a'` instead of `delete obj.a`
    deleteProperty: (name) ->
      value = @[name]
      delete @[name]
      value

    # Syntaxic sugar, hasProperty, hasKey - `obj.hasKey 'a'` instead of `a of obj`
    hasProperty: (name) -> name of @
    hasKey: (name) -> name of @

    # Object inspection.
    inspect: -> JSON.stringify @

  # String.
  _htmlEscape = ->
    @replace(/&(?!\w+;|#\d+;|#x[\da-f]+;)/gi, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').
      replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;')

  String.prototype.extendWithoutEnumeration
    # Escaping HTML.
    htmlEscape: _htmlEscape
    escape: _htmlEscape

    # Escaping Uri.
    uriEscape: -> encodeURIComponent @
    uriUnescape: -> decodeURIComponent @

    empty: -> @length == 0

  # Array.
  blankCallback = ->
  Array.prototype.extendWithoutEnumeration
    deleteAt: (index) ->
      index = @length + index if index < 0
      @splice(index, 1)
    deleteIf: (condition) ->
      toDelete = []
      @each (v, i) -> toDelete.add(i) if condition(v)
      toDelete.each (i) => @deleteAt(i)
    delete: (obj) -> @deleteIf (o) -> o == obj
    include: (obj) -> @indexOf(obj) != -1
    extractCallback: -> if _.isFunction(@last()) then @pop() else blankCallback
    empty: -> @length == 0
    clear: ->
      @splice(0, @length) if @length > 0
    update: (list) ->
      @clear()
      list.each (v) => @push(v)
    add: (args...) -> @push args...

  # Global object.
  window.global = window unless global?

  # Shortcut for printing.
  global.p = (args...) ->
    if args.size() > 1
      console.log args.inspect()
    else
      console.log args.first()?.inspect()

  # Alternative version of `throw` to fix problem with stacktrace.
  global.raise = (msg) -> throw new Error(msg)