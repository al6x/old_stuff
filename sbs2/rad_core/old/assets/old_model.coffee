# ### Model.
class Rad.Model extends Backbone.Model
  valid: -> !@get('errors')

  empty: -> @attributes.size() == 0

  save: (callback) ->
    path = if @isNew() then 'create' else 'update'
    @call path, callback

  delete: (callback) -> @call 'delete', callback

  fetch: -> throw "disabled, use 'read'!"
  destroy: -> throw "disabled, use 'delete'!"

  @read: (id, callback) ->
    @call_with_get id, callback

  @all: (args...) ->
    @collectionClass().new().all args...

  # Low level call methods.

  _call: (path, data, options, callback) ->
    # Adding model to data.
    model = @toJSON()
    model.deleteProperty 'errors'
    data.push model

    # Updating model in callback.
    originalCallback = callback
    callback = (data) =>
      # Updating model.
      data.errors = null unless data.hasProperty 'errors'
      @set data
      originalCallback @ if originalCallback

    # Calling server.
    @constructor._call path, data, options, callback

  @_call: (path, data, options, callback) ->
    resource = _.valueOf @resource
    throw 'no resource!' unless resource
    path = "#{resource}/#{path}"

    originalCallback = callback
    callback = (data) =>
      model = @new data
      originalCallback model if originalCallback

    rad.server().call path, data, options, callback

  @collectionClass: ->
    throw "no collection!" unless @Collection
    @Collection

# ### Collection.
class Rad.Collection extends Backbone.Collection
  fetch: -> throw "disabled, use 'read'!"

  all: (args...) ->
    @call_with_get 'all', args...

  _call: (path, data, options, callback) ->
    throw "no model for collection!" unless @model

    resource = _.valueOf @model.resource
    throw 'no resource!' unless resource
    path = "#{resource}/#{path}"

    originalCallback = callback
    callback = (data) =>
      @reset data
      originalCallback @ if originalCallback

    rad.server().call path, data, options, callback

# Adding server call helpers.
[Rad.Model, Rad.Model.prototype, Rad.Collection.prototype].each (target) ->
  # target.extend
  target.call = (path, args...) ->
    callback = args.extractCallback()
    data     = args.first() || []
    @_call path, data, {}, callback

  target.call_with_get = (path, args...) ->
    callback = args.extractCallback()
    data     = args.first() || []

    @_call path, data, {type: 'get'}, callback