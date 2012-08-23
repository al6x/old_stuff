_      = require 'underscore'

global.expect  = require 'expect.js'
global.p = (args...) -> console.log args...

rest = require '../rest-lite'

# Disabling logger.
rest.logger = null

# Stubbing server.
rest.Service.prototype.call = (method, path, data, options, callback) ->
  @stubs ?= {}
  stub = @stubs["#{method}:#{path}"] || throw new Error "no stub for #{method}:#{path}!"
  stub null, data, options, callback

rest.Service.prototype.stub = (method, path, callback) ->
  @stubs ?= {}
  @stubs["#{method}:#{path}"] = callback
