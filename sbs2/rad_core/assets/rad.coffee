###
  rad.require '/rad/prepare.coffee'
  rad.require '/rad/misc.coffee'
  rad.require '/rad/jquery.coffee'
  rad.require '/rad/backbone.coffee'
  rad.require '/rad/models.coffee'
  rad.require '/rad/server.coffee'
  rad.require '/rad/form_builder.coffee'
###

# Logger.
class Logger
  info: console.log.bind(console)
  debug: console.debug.bind(console)
  warn: console.warn.bind(console)
  error: console.error.bind(console)

global.logger = Logger.new()