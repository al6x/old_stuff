###
rad.require '/vendor/jquery.js'
rad.require '/vendor/jquery.url.js'

rad.require '/lib/stdlib.coffee'
rad.require '/lib/dependency-injector.coffee'

rad.require '/vendor/backbone.js'
###

# Rad.
class global.Rad

# Adding dependency injection to Rad.
Rad extends DependencyInjector

global.rad = Rad.new()
rad.initializeDi()