# ### Events.
#
# Making `trigger` method by default trigger the `change` event,
# and `bind` listen to `all` events, if not explicitly specified.

[trigger, bind] = [Backbone.Events.trigger, Backbone.Events.bind]

[
  Backbone.Events
  Backbone.Model.prototype
  Backbone.Collection.prototype
  Backbone.Router.prototype
].each (obj) ->
  obj.extend
    bind: (args...) ->
      args.unshift 'all' unless _.isString(args.first())
      bind.apply @, args

    trigger: (args...) ->
      args.unshift 'change' unless _.isString(args.first())
      trigger.apply @, args

# ### View.
class Rad.View extends Backbone.View
  # Automatically wrapping element in jQuery wrapper.
  _ensureElement: (args...) ->
    result = super args...
    @el = $ @el
    result

# ### Router.
#
# Fix for Backbone.Router - making it trigger route, even if it's the same.
`
(function(){
  var hashStrip = /^#*/;
  Backbone.History.prototype.navigate = function(fragment, triggerRoute) {
    var frag = (fragment || '').replace(hashStrip, '');
    // if (this.fragment == frag || this.fragment == decodeURIComponent(frag)) return;
    if (this._hasPushState) {
      var loc = window.location;
      if (frag.indexOf(this.options.root) != 0) frag = this.options.root + frag;
      this.fragment = frag;
      window.history.pushState({}, document.title, loc.protocol + '//' + loc.host + frag);
    } else {
      window.location.hash = this.fragment = frag;
      if (this.iframe && (frag != this.getFragment(this.iframe.location.hash))) {
        this.iframe.document.open().close();
        this.iframe.location.hash = frag;
      }
    }
    if (triggerRoute) this.loadUrl(fragment);
  }
})();
`

# Allowing to specify routes without names,
# with any parameters and before/after events.
class Rad.Router extends Backbone.Router
  @routeNameCounter: 0
  randomRouteName: ->
    Rad.Router.routeNameCounter += 1
    Rad.Router.routeNameCounter.toString()

  # Setting `path` and `params` and adding named parameters from route tof
  # params.
  route: (route, handler) ->
    super "#{route}*splat", @randomRouteName(), (args...) =>
      rad.beginScope 'page'

      @_setPathAndParams()

      # Extracting named params names from route name.
      namedParam = /:([\w\d]+)/g;
      reStr = route.replace namedParam, "([^\/]*)"
      re = new RegExp reStr
      namedParamsNames = re.exec(route)?.slice(1) || []
      namedParamsNames = namedParamsNames.map (name) -> name.slice(1)

      # Backbone router doesn't named params to params, so we has to
      # do it by hand.
      splat = args.pop()
      namedParams = args
      namedParamsNames.each (name, i) -> rad.params()[name] = namedParams[i]

      logger.info "processing #{rad.path()} with #{rad.params().inspect()}"

      @trigger "route:before"
      handler()
      @trigger "route:after"

  # Add named path like `userPath(user)`.
  namedRoute: (name, route) ->
    if _.isFunction(route)
      @[name] = route
    else
      @[name] = (args...) ->
        args.unshift route
        @buildUrl args...

    # Adding navigation helper, like `goToRegisterPath`.
    navigationHelperName = "goTo" + name[0].toUpperCase() + name.slice(1)
    @[navigationHelperName] = (args...) -> @navigate @[name](args...)

  buildUrl: (path, params = {}, withPersistentParams = true) ->
    params = params.clone()

    # Adding persistent parameters.
    if withPersistentParams and @persistentParams
      @persistentParams.each (name) =>
        params[name] = rad.params()[name] unless params.hasKey name

    # Skipping special parameters.
    if @skipParams
      @skipParams.each (k) -> params.deleteProperty(k)

    # Removing blank parameters.
    toDelete = []; params.each((v, k) -> toDelete.push(k) unless v)
    toDelete.each (k) -> params.deleteProperty(k)

    # Adding root.
    path = @root + path if @root

    $.buildUrl path, params

  back: =>
    if return_to = rad.params().return_to
      @navigate return_to
    else if window.history.length > 0
      window.history.go(-1)
    else
      @navigate @defaultPath() || '/'

  ensureReturnTo: =>
    unless rad.params().hasProperty 'return_to'
      @navigate rad.url(), {return_to: (@defaultPath() || '/')}, false
      @_setPathAndParams()

  navigate: (path, params = {}, triggerRoute = true) =>
    url = $.buildUrl.apply($, [path, params])
    super url, triggerRoute
    null

  defaultPath      : (params = {}) -> @buildUrl @defaultRoute, params
  goToDefaultPath  : (params = {}) -> @navigate @defaultPath(params)

  _setPathAndParams: ->
    [path, params] = $.parseUri(window.location.toString())
    rad.setUrl $.buildUrl(path, params)

    path = path[@root.size()..path.size()] if @root
    rad.setPath path
    rad.setParams params

# Namespaces.
global.Models = {}
global.Views = {}
global.Routers = {}
global.Controllers = {}

# Rad.
Rad.prototype.extend Backbone.Events