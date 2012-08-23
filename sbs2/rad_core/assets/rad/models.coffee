# Model.
class Rad.Model
  constructor: (attrs = {}) ->
    @errors = {}
    @extend @defaults if @defaults
    @extend attrs

  valid: ->
    @errors = {}
    @validate() if @validate
    @errors.size() == 0

  invalid: -> !@valid()

  set: (attrs, options = {}) ->
    @extend attrs
    @trigger() unless options.silent

  attributeNames: ->
    names = []
    @each (v, k) -> names.add k unless /^_|^id|^errors$/.test(k)
    names

  attributes: ->
    attrs = {}
    @attributeNames().each (name) => attrs[name] = @[name]
    attrs

Rad.Model.prototype.extend Backbone.Events

# Remote Model.
class Rad.RemoteModel extends Rad.Model
  isNew: -> !@id

  valid: -> @errors.size() == 0

  create: (args...) ->
    [callback, params] = [args.extractCallback(), args.first() || {}]
    params.attributes = true
    @call "/create", params, callback

  update: (args...) ->
    [callback, params] = [args.extractCallback(), args.first() || {}]
    params.attributes = true
    @call "/#{@id}/update", params, callback

  delete: (args...) -> @call "/#{@id}/delete", args...

  save: (args...) ->
    if @isNew() then @create(args...) else @update(args...)

  refresh: (args...) ->
    raise "can't refresh non-existing model!" if @isNew()
    @call "get:/#{@id}", args...

  original: -> @_original

  @read: (id, callback) ->
    @call "get:/#{id}", callback

  @all: (args...) -> @call 'get:', args...

  unmarshal: (data) ->
    newModel = @isNew()

    properties = ['id', 'errors']
    properties.concat @attributeNames()
    properties.each (name) =>
      @deleteProperty name

    @_original = data
    @extend data
    @errors ||= {}

    # We need to clean id if model is new and hasn't been successfully saved.
    @deleteProperty 'id' if newModel and @invalid()

    @trigger()
    @

  marshal: (params) ->
    if params.attributes
      params = params.clone()
      params.deleteProperty 'attributes'
      params.extend @attributes()
    else
      params

  # Server calling and model marshalling.

  call: (path, args...) ->
    [callback, params] = [args.extractCallback(), args.first() || {}]

    data = @marshal params

    # Building path.
    resource = _.valueOf(@constructor.resource, @) || raise('no resource!')
    path = "#{resource}#{path}"

    # Calling server.
    rad.server().call path, data, (response) =>
      @unmarshal response
      callback @ if callback

  @call: (path, args...) ->
    [callback, params] = [args.extractCallback(), args.first() || {}]

    # Building path.
    resource = _.valueOf(@resource) || raise('no resource!')
    path = "#{resource}#{path}"

    # Calling server.
    rad.server().call path, params, (response) =>
      raise "model not exist (#{path.replace('get:', '')})!" unless response

      # Building collection of models or single model.
      result = if _.isArray(response)
        models = response.map (data) => @new().unmarshal(data)
        Rad.Collection.new(models)
      else
        @new().unmarshal(response)

      callback result if callback

# Collection.
class Rad.Collection extends Array
  constructor: (list) ->
    @update list if list

Rad.Collection.prototype.extend Backbone.Events

# Making `trigger` method by default trigger the `change` event if not explicitly specified.
# trigger = Backbone.Events.trigger
# [Rad.Model.prototype, Rad.RemoteModel.prototype, Rad.Collection].each (obj) ->
#   obj.trigger = (args...) ->
#     args.unshift 'change' unless _.isString(args.first())
#     trigger.apply @, args