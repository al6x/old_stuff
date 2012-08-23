DependencyInjector = require 'dependency-injector'
_ = require 'underscore'
require 'mary'

describe "Dependency Injection", ->
  di = null

  beforeEach ->
    di = new DependencyInjector()
    di.initializeDi()

  it "should register, create and update component", ->
    di.register 'a', -> 'a1'
    di.get('a').should be: 'a1'
    di.set 'a', 'a2'
    di.get('a').should be: 'a2'

  it "should generate helper methods", ->
    di.register 'a', -> 'a1'
    di.a().should be: 'a1'
    di.setA 'a2'
    di.a().should be: 'a2'

  it "should raise error if there's no initializer", ->
    (-> di.get('a')).should raise: 'component :a not registered!'

  describe "Application Scope", ->
    it "should create object only once", ->
      di.register 'a', -> []
      di.a().should be: []
      di.a().push 1
      di.a().should be: [1]

  describe "Instance Scope", ->
    it "should every time create new object", ->
      di.register 'a', 'instance', -> []
      di.a().should be: []
      di.a().push 1
      di.a().should be: []

  describe "Custom Scope", ->
    it "should raise error if scope not started", ->
      di.register 'a', 'page'
      (-> di.get('a')).should raise: "scope 'page' for 'a' not started!"
      (-> di.set('a', 'component a')).should raise: "scope 'page' for 'a' not started!"

    it "should create new object every time scope beginScoped", ->
      di.register 'menu', 'page', -> []

      di.beginScope 'page'
      di.menu().push 'home'
      di.menu().should be: ['home']

      di.beginScope 'page'
      di.menu().should be: []

      di.endScope 'page'
      (-> di.menu()).should raise: "scope 'page' for 'menu' not started!"

    it "should save components of custom scope in container", ->
      di.register 'menu', 'page', -> 'some menu'
      container = {}
      di.beginScope 'page', container
      _(container['menu']).shouldNot().beDefined()
      di.menu()
      container['menu'].should be: 'some menu'
      returnValue = di.endScope('page')
      returnValue.should be: container

  describe "Callbacks", ->
    it "should fire callback after component instantiation", ->
      check = []

      di.after 'a', ->
        di.get('a').should be: 'component a'
        check.push 'called'
      check.should be: []

      di.register 'a', -> 'component a'
      di.get('a')
      check.should be: ['called']

    it "should fire callback immediatelly if component already initialized", ->
      check = []

      di.register 'a'
      di.set 'a', 'component a'

      di.after 'a', ->
        di.get('a').should == 'component a'
        check.push 'called'

      check.should be: ['called']

    it "should fire callback if component assigned manually", ->
      check = []

      di.after 'a', ->
        di.get('a').should be: 'component a'
        check.push 'called'

      di.register 'a'
      di.set 'a', 'component a'

      check.should be: ['called']

  describe "Scope Callbacks", ->
    it "should fire callback after starting scope", ->
      check = []

      di.afterScope 'page', ->
        check.push 'called'
      check.should be: []

      di.beginScope 'page'
      check.should be: ['called']

    it "should fire scope callback immediatelly if scope already initialized", ->
      check = []

      di.beginScope 'page'
      di.afterScope 'page', ->
        check.push 'called'

      check.should be: ['called']

      check.should be: ['called']
  it "should be able to be mixed into other classes", ->
    class Spec.Di
    Spec.Di extends DependencyInjector

    di = new Spec.Di()
    di.initializeDi()

    di.register 'a', -> 'component a'
    di.a().should be: 'component a'