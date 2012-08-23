# Namespace for spec related variables.
global.Spec = {}

# Disabling logger.
logger.extend
  info: ->
  debug: ->

# User interaction emulation.
class Spec.Client

  text: -> $('#application').text().replace(/\s+/g, ' ')

  html: -> $('#application').html().replace(/\s+/g, ' ')

  button: (text) ->
    buttons = $("button:contains('#{text}')")
    raise("no buttons with '#{text}' text!") if buttons.size() == 0
    raise("found #{buttons.size()} buttons with '#{text}' text!") if buttons.size() > 1
    buttons

  click: (text) -> @button(text).trigger('click')

global.client = Spec.Client.new()

# Server Stub.
class Spec.Server
  constructor: ->
    @clear()

  clear: ->
    @stubs = {}
    @cachedResponses = {}

  stub: (path, response) ->
    @stubs[path] = response

  call: (path, args...) =>
    callback = args.extractCallback()
    params   = args.first() || {}

    # Removing request method.
    path = path.replace 'get:', ''

    response = @cachedResponses.deleteProperty(path) || @stubs.deleteProperty(path)
    raise "stub response for '#{path}' is undefined!" if !response and response != null
    response = _.valueOf response
    callback response if callback

rad.register 'server', ->
  Spec.Server.new()

class Spec.Factory
  constructor: ->
    @initializers = {}
    @counter = 0

  build: (name, attributes = {}) ->
    [klass, initializer] = @initializers[name] || raise("no builder for #{name}!")
    model = new klass()
    initializer model, false
    model.extend attributes
    model

  create: (name, attributes = {}) ->
    [klass, initializer] = @initializers[name] || raise("no builder for #{name}!")
    model = new klass()
    initializer model, true
    model.extend attributes
    model

  next: -> @counter += 1

  define: (name, args...) ->
    [klass, initializer] = if args.size() == 1
      [Object, args.first()]
    else
      args

    @initializers[name] = [klass, initializer]

global.factory = Spec.Factory.new()