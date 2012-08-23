# ### jQuery extensions.
$.extend
  # Compiled templates.
  templates: {}

  # Get template.
  template: (name) ->
    template = @templates[name]
    unless template
      id = "#templates#{name.replace /\//g, '-'}"
      source = @(id).html() || raise("no template #{name}")
      template = @compileTemplate source
      @templates[name] = template
    template

  # Render template.
  render: (name, context = {}) -> @template(name)(context)

  compileTemplate: (args...) -> _.template args...

  # Build DOM element from hash.
  buildAsString: (name, others...) ->
    [content, attrs] = [null, {}]
    content = others.first() if _.isString(others.first())
    attrs = others.last() if _.isObject(others.last())

    strAttrs = ""
    attrs.each((v, k) -> strAttrs += " #{k}=\"#{v}\"")

    if content
      "<#{name}#{strAttrs}>#{content}</#{name}>"
    else
      "<#{name}#{strAttrs}></#{name}>"

  build: (args...) ->
    html = if /^\//.test(args.first())
      $.render args...
    else
      @buildAsString(args...)
    @ html

  # Build Uri.
  buildUrl: (path, params = {}) ->
    params = params.clone()

    host = params.deleteProperty('host')
    port = params.deleteProperty('host') || rad.router().port
    if host
      path = "http://#{host}#{':' + port if port}#{path}"

    if params.size() > 0
      path += if /\?/.test(path) then '&' else '?'
      path + params.toArray2().map((pair) ->
        "#{pair.first().toString().uriEscape()}=#{pair.last().toString().uriEscape()}"
      ).join('&')
    else
      path

  # Parsing Uri.
  parseUri: (uri) ->
    parsedUri = $.url(uri)
    params = {}
    parsedUri.param().each (v, k) ->
      params[k] = v.uriUnescape()
    [parsedUri.attr('path'), params]

$.fn.extend
  # Serialize as Hash.
  serializeHash: ->
    form = {}
    @serializeArray().each (pair) -> form[pair.name] = pair.value

    # Adding unchecked and rewriting already added radio and checkboxes.
    for e in @find('input[type=checkbox],input[type=radio]')
      form[$(e).attr('name')] = e.checked

    form

  # Clear element.
  clear: -> @html('')

  # Replacing html of element with html of rendered template.
  renderWith: (name, context = {}) -> @html $.render(name, context)

  # Update element's content and attributes
  updateWith: (element) ->
    @html element.html()
    ['class', 'id'].each (name) => @attr(name, element.attr(name))