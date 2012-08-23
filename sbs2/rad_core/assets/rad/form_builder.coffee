# Form Builder.
class FormBuilder
  baseErrors: (errors) ->
    $.render('/utils/formErrors', errors: errors) if errors and !errors.isEmpty()

  textField: (name, value = "", options = {}) ->
    @_build name, options, (attrs) ->
      $.buildAsString 'input', attrs.extend(type: 'text', value: value)

  passwordField: (name, value = "", options = {}) ->
    @_build name, options, (attrs) ->
      $.buildAsString 'input', attrs.extend(type: 'password', value: '')

  checkboxField: (name, checked = false, options = {}) ->
    @_build name, options, (attrs) ->
      attrs.checked = 'checked' if checked
      $.buildAsString 'input', attrs.extend(type: 'checkbox', value: 'true')

  textareaField: (name, value = '', options = {}) ->
    @_build name, options, (attrs) ->
      $.buildAsString 'textarea', value, attrs

  selectField: (name, selected = '', values = [], options = {}) ->
    @_build name, options, (attrs) ->
      buff = "\n"
      values.each (pair) ->
        [name, value] = if _.isArray(pair) then pair else [pair, pair]
        opts = {value: value}
        opts.selected = 'selected' if value == selected
        buff += $.buildAsString 'option', name, opts
        buff += "\n"
      $.buildAsString 'select', buff, attrs

  _build: (name, options, build) ->
    options = options.clone().extend
      name  : name
      build : (attrs = {}) -> build attrs.extend(name: name)
    options.label ||= rad.locale().t name
    desc_key = "#{name}_description"
    options.description ||= rad.locale().t desc_key if rad.locale().has desc_key
    $.render '/utils/formField', options


# Integration with Model.
class ModelFormBuilder
  constructor: (@model) ->
    @formBuilder = FormBuilder.new()

  baseErrors: ->
    errors = @get('errors')?['base']?.uniq()
    @formBuilder.baseErrors errors

  get: (name) ->
    if @model instanceof Backbone.Model
      @model.get(name)
    else
      value = @model[name]
      value = value() if _.isFunction value
      value

  selectField: (name, values = [], options = {}) ->
    @formBuilder.selectField name, @get(name), values, @getOptionsWithErrors(name, options)

  getOptionsWithErrors: (name, options) ->
    options = options.clone()
    options.errors = @get('errors')?[name]?.uniq()
    options

['textField', 'passwordField', 'checkboxField', 'textareaField'].each (method) ->
  ModelFormBuilder.prototype[method] = (name, options = {}) ->
    @formBuilder[method] name, @get(name), @getOptionsWithErrors(name, options)

# Integration with jQuery.
$.extend formBuilder: (args...) ->
  if args.size() == 1
    fun = args.first()
    fun(FormBuilder.new())
  else if args.size() == 2
    [model, fun] = args
    fun(ModelFormBuilder.new(model))
  else
    raise 'invalid arguments!'