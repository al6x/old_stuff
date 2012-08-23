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
# You can also use Dr. Marys's own [spec](marySpec.html) as a
# sample ([run it](../runSpecs.html) and see the result).
#
# Actually it's just a thin wrapper around the [Jasmine](http://pivotal.github.com/jasmine)
# BDD library, download [mary.js](https://github.com/alexeypetrushin/mary) and include it in Your scripts.
#
# The project is [hosted on GitHub](https://github.com/alexeypetrushin/mary), You can report bugs and discuss features
# on the [issues page](https://github.com/alexeypetrushin/mary/issues).
#
# Copyright (c) Alexey Petrushin [http://petrush.in](http://petrush.in), released under the MIT license.

# ### Source Code

# Global reference, usually it's the `window`, You may
# override the `global` variable in environments other than Browser.
unless global?
  global = if window? then window else {}

global.Mary = Mary = {}

# Adding some useful matchers to Jasmine.
jasmine.Matchers.prototype.toInclude = (expected) ->
  @actual.include expected

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
unless global._
  global._ = (obj) ->
    wrapper = new Object()
    wrapper._wrapped = obj
    wrapper