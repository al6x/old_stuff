# If it's Browser, making it looks like "standard" JS.
global ?= window
dummy = ->
console ?= info: dummy, warn: dummy, error: dummy
console.debug ?= dummy

util = try
  require 'util'
catch error
  {inspect: (data) -> JSON.stringify(data)}

_ = global._ || require 'underscore'

# Global Namespace.
Rest =
  # Default options.
  options: {}

  # Override with custom logger or set to `null` to disable.
  logger: console

  service: (url, options) -> new Rest.Service url, options

# Service.
class Rest.Service
  constructor: (@url, @options = {}) ->
    @cache = {}

  log: (msgs) -> Rest.logger?[type] "      rest: #{msg}" for type, msg of msgs

  resource: (name, options) -> new Rest.Resource name, options, @

  call: (method, path, data, callback) ->
    data ?= {}
    options = _.extend {}, (@options || {}), (options || {})
    url = "#{@url}#{path}"
    @log info: "#{method}:#{url} #{util.inspect data}, #{util.inspect options}"

    # Checking cache.
    key = "#{method}:#{path}"
    if resp = @cache[key]
      delete @cache[key]
      return callback null, resp








    # Converting arguments to jQuery.ajax format.
    error = (jqXHR, textStatus, errorThrown) ->
      callback {jqXHR: jqXHR, textStatus: textStatus, errorThrown: errorThrown}
    success = (data, textStatus, jqXHR) ->
      callback null, data

    params =
      type        : method
      url         : url
      dataType    : 'json'
      contentType : 'application/json'
      data        : JSON.stringify(data)
      error       : error
      success     : success

    _(params).extend options

    $.ajax params

  cache: (method, path, data) ->
    @cache["#{method}:#{path}"] = data

# Resource.
class Rest.Resource
  constructor: (@name, @options = {}, @server) ->

  create: (doc, callback) -> @call 'post', '', doc, callback

  update: (id, doc, callback) -> @call 'put', id, doc, callback

  delete: (id, callback) -> @call 'delete', id, {}, callback

  get: (first, args...) ->
    if _.isString(first) or _.isNumber(first)
      @getOne first, args...
    else
      @getCollection first, args...

  getOne: (id, callback) ->
    throw new Error "callback required!" unless callback
    [data, options] = args
    options ?= {}
    @call 'get', id, '', data, options, (err, data) =>
      data = Rest.fromRest data, @ unless err or options.raw == true
      callback err, data

  getCollection: (args..., callback) ->
    throw new Error "callback required!" unless callback
    [data, options] = args
    options ?= {}
    @call 'get', '', data, options, (err, data) =>
      unless err or options.raw == true
        data = (Rest.fromRest v, @ for v in data)
      callback err, data

  # call hMethod, id, method, obj?, options?
  # call hMethod, method, obj?, options?
  call: (hMethod, args..., callback) ->
    throw new Error "callback required!" unless callback
    if _.isString(args[1]) or _.isNumber(args[1])
      [id, method, data, options] = args
    else
      [method, data, options] = args
    mPath = if method == '' then '' else "/#{method}"
    path = if id then "/#{@name}/#{id}#{mPath}" else "/#{@name}#{mPath}"
    data ?= {}
    options ?= {}
    @server.call hMethod, path, data, options, callback

# Universal exports `module.exports`.
if module?
  module.exports = Rest
else
 window.RestLite = Rest