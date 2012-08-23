class Rad.Server
  constructor: ->
    @cachedResponses = {}

  call: (path, args...) =>
    callback = args.extractCallback()
    params   = args.first() || {}

    # Request method.
    type = if /get:/.test path
      path = path.replace 'get:', ''
      'get'
    else
      'post'

    # AJAX options.
    options = {
      type        : type
      dataType    : 'json'
      contentType : 'application/json'
      error: (jqXHR, textStatus, errorThrown) ->
        logger.error "can't call server (#{textStatus})!"
    }

    # Url and data.
    if options.type == 'get'
      options.url = rad.router().buildUrl path, params
    else
      options.url = rad.router().buildUrl path
      options.data = JSON.stringify params

    # Returning cached response from server if defined.
    if response = @cachedResponses.deleteProperty(options.url)
      callback response if callback
      return

    # Processing result of call.
    if callback
      options.success = (data, textStatus, jqXHR) ->
        # logger.info "SERVER: processing '#{JSON.stringify(data)}' from #{path}"
        callback data

    $.ajax options
    null

  cacheResponse: (path, response) ->
    @cachedResponses[path] = response

rad.register 'server', ->
  Rad.Server.new()