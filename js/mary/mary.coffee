# [Dr. Mary](https://github.com/alexeypetrushin/mary) -
# JavaScript (CoffeeScript) BDD in Object-Oriented way.
#
#     'Mary'.should match: /ry/
#     'Mary'.should be: 'Mary'
#     'Mary'.should contain: 'ry'
#     'Mary'.should beEqualTo: 'Mary'
#
#     10.should beGreaterThan: 9
#
#     fun = -> throw 'some bug'
#     (-> fun()).should throw: 'some bug'
#
#     _(null).should be: null
#
# Every matcher also available in form of method.
#
#     'Mary'.should().match /ry/
#     'Mary'.should().be 'Mary'
#     'Mary'.should().contain 'ry'
#     'Mary'.should().beEqualTo 'Mary'
#
#     10.should().beGreaterThan 9
#
#     fun = -> throw 'some bug'
#     (-> fun()).should().throw 'some bug'
#
#     _(null).should().be null
#
# Mocks and stubs.
#
#     class Bob
#       hi: -> 'hi'
#
#     bob = new Bob()
#     bob.spyOn 'hi', andReturn: 'Hello'
#     bob.hi().should be: 'Hello'
#     bob.hi.should().haveBeenCalled()
#
# ### Control flow helpers.
#
# `it.async` and `it.next` helpers allows You to write asynchronous specs. `it.async` will pause
# specs execution and will wait untill `it.next` will be called.
#
#     it.async "should save object to collection", ->
#       db.collection 'units', (err, collection) ->
#         obj = name: 'Probe',  status: 'alive'
#         collection.create obj, (err, result) ->
#           _(err).should be: null
#           it.next()
#
# `it.sync` helper designed to be used with fiber-aware code and wraps the spec inside
# of [Fiber](https://github.com/laverdet/node-fibers), the previous sample will
# looks like this.
#
#     it.async "should save object to collection", ->
#       collection = db.collection 'units'
#       obj = name: 'Probe',  status: 'alive'
#       collection.create obj
#
# In short, `it.sync` helps to write asynchrnous code as if it's synchronous. If You need more samples
# please take a look at [Mongo Model](http://alexeypetrushin.github.com/mongo-model) all its
# specs are writeen using `it.sync`.
#
#
# ### Installation
#
# Node.JS `npm install mary`
#
# Broser `add jasmine.js and mary.js to the page`
#
# You can also use Dr. Marys's own spec as a sample, run it with `cake spec` and see the result.
#
# Dr. Mary is a thin wrapper around the [Jasmine](http://pivotal.github.com/jasmine) and
# [jasmine-node](https://github.com/mhevery/jasmine-node) libraries.
#
# The project is [hosted on GitHub](https://github.com/alexeypetrushin/mary), You can report bugs and discuss features
# on the [issues page](https://github.com/alexeypetrushin/mary/issues).
#
# Copyright (c) Alexey Petrushin [http://petrush.in](http://petrush.in), released under the MIT license.

# ### Source Code

# Checking for presence of Jasmine.
throw new Error("no jasmine (mary requires jasmine BDD framework)!") unless jasmine?

# Adding some useful matchers to Jasmine.
jasmine.Matchers.prototype.toInclude = (expected) ->
  if @actual.indexOf
    @actual.indexOf(expected) >= 0
  else
    expected of @actual

jasmine.Matchers.prototype.toInclude = jasmine.Matchers.matcherFn_(
  'toInclude',
  jasmine.Matchers.prototype.toInclude
)

# Mary.
Mary = {}

# Matcher.
class Mary.Matcher
  constructor: (@obj) ->
    @expect = expect obj

  # Expectations with expected value.
  include       : (o) -> @expect.toInclude o
  beEqualTo     : (o) -> @expect.toEqual o
  be            : (o) -> @expect.toEqual o
  match         : (o) -> @expect.toMatch o
  contain       : (o) -> @expect.toContain o
  beLessThan    : (o) -> @expect.toBeLessThan o
  beGreaterThan : (o) -> @expect.toBeGreaterThan o
  throw         : (o) -> @expect.toThrow o
  raise         : (o) -> @expect.toThrow o

  # Expectations without expected value.
  beNull        : ()  -> @expect.toBeNull()
  beTrue        : ()  -> @expect.toBeTruthy()
  beFalse       : ()  -> @expect.toBeFalsy()
  beDefined     : ()  -> @expect.toBeDefined()
  beUndefined   : ()  -> @expect.toBeUndefined()

  # Stubs and mocks.
  haveBeenCalled      : ()  -> @expect.toHaveBeenCalled()
  haveBeenCalledWith  : (args...)  ->
    @expect.toHaveBeenCalledWith.apply(@expect, args)

  # Apply matchers defined as hash, i.e. `be: null`.
  applyHashMatchers: (args) ->
    if args then for matcher, value of args
      @[matcher](value)
    @

# Negative matcher.
class Mary.NegativeMatcher extends Mary.Matcher
  constructor: (@obj) ->
    @expect = expect(obj).not

# `should` and `shouldNot` methods.
getValue = (obj) ->
  if obj.hasOwnProperty('_wrapped')
    obj._wrapped
  else
    obj.valueOf()

methods =
  should: (args) ->
    new Mary.Matcher(getValue(@)).applyHashMatchers(args)

  shouldNot: (args) ->
    new Mary.NegativeMatcher(getValue(@)).applyHashMatchers(args)

  spyOn: (method, options) ->
    spy = spyOn(getValue(@), method)
    if options then for method, arg of options
      spy[method](arg)
    spy

# Extending native types with `should` methods.
types = [
  Object.prototype
  String.prototype
  Number.prototype
  Array.prototype
  Boolean.prototype
  Date.prototype
  Function.prototype
  RegExp.prototype
]

for type in types
  for name, method of methods
    Object.defineProperty type, name,
        enumerable: false
        writable: true
        configurable: true
        value: method

# It's impossible to extend `null` and `undefined`,
# so we use a wrapper, i.e.  `_(null).shouldBe().undefined()`.
#
# Sometimes such wrapper may be already defined (by underscore.js
# for example), if it's not we defining it.
wrapper = (obj) ->
  wrapper = new Object()
  wrapper._wrapped = obj
  wrapper

# Flow.
#
# Sample:
#
#   it.async "should provide handy shortcuts to databases", ->
#     $db.collection 'test', (err, collection) ->
#       collection.name.should be: 'test'
#       it.next()
#

# Block and waits untill `it.next()` is called.
it.async = (desc, func) ->
  it desc, ->
    it.finished = false
    func()
    waitsFor (-> it.finished), desc, 1000

# Resumes execution of `it.async`.
it.next = (e) ->
  it.lastError = e
  it.finished = true

# Wraps spec into Fiber.
it.sync = (desc, callback) ->
  try
    require 'fibers'
  catch e
    console.log """
      WARN:
        You are trying to use synchronous mode.
        Synchronous mode is optional and requires additional `fibers` library.
        It seems that there's no such library in Your system.
        Please install it with `npm install fibers`."""
    throw e

  it.async desc, ->
    Fiber(->
      callback()
      it.next()
    ).run()

# Setting up globals.
if module? and module.exports?
  exports.Mary = Mary
  exports._    = wrapper

if window?
  window.Mary = Mary
  window._    ||= wrapper