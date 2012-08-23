# Localization.

class Rad.Locale
  t: (key, options) ->
    msg = @[@_current()]?[key]
    unless msg
      msg = "no translation for #{key}!"
      logger.warn msg
    options.each((v, k) -> msg = msg.replace "{{#{k}}}", v) if options
    msg

  has: (key) -> !!@[@_current()]?[key]

  _current: -> @current || @default || 'en'

global.t = (key, options) -> rad.locale().t key, options

rad.register 'locale', -> Rad.Locale.new()

# Path & Params.
rad.register 'url',    'page'
rad.register 'path',   'page'
rad.register 'params', 'page'

# Theme.
rad.register 'theme'

# Config
rad.register 'config', -> {}