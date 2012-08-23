_ = require('../mary')._

Array.prototype.include = (obj) ->
  @indexOf(obj) != -1

describe 'Dr. Mary BDD', ->
  it 'matchers showcase', ->
    'Mary'.should match: /ry/
    'Mary'.should be: 'Mary'
    'Mary'.should contain: 'ry'
    'Mary'.should beEqualTo: 'Mary'

    10.should beGreaterThan: 9

    fun = -> throw 'some bug'
    (-> fun()).should throw: 'some bug'

    _(null).should be: null

  it 'matchers showcase as methods', ->
    'Mary'.should().match /ry/
    'Mary'.should().be 'Mary'
    'Mary'.should().contain 'ry'
    'Mary'.should().beEqualTo 'Mary'

    10.should().beGreaterThan 9

    fun = -> throw 'some bug'
    (-> fun()).should().throw 'some bug'

    _(null).should().be null

  it 'mocks & stubs showcase', ->
    class Bob
      hi: -> 'hi'

    bob = new Bob()
    bob.spyOn 'hi', andReturn: 'Hello'
    bob.hi().should be: 'Hello'
    bob.hi.should().haveBeenCalled()

  it 'matchers with expected value', ->
    cases =
      beEqualTo     : ['a', 'a', 'b']
      be            : ['a', 'a', 'b']
      match         : ['abc', /b/, /d/]
      contain       : ['abc', 'b', 'd']
      beLessThan    : [3, 4, 2]
      beGreaterThan : [3, 2, 4]
      throw         : [(-> throw 'a'), 'a', 'b']
      raise         : [(-> throw 'a'), 'a', 'b']

    for matcher, [value, expectation, negativeExpectation] of cases
      # first form - `value.should matcher: expectation`
      args = {}
      args[matcher] = expectation
      value.should args

      args[matcher] = negativeExpectation
      value.shouldNot args

      # second form - `value.should().matcher(expectation)`
      value.should()[matcher](expectation)
      value.shouldNot()[matcher](negativeExpectation)

  it 'matcher without expected value', ->
    cases =
      beTrue          : [true, false]
      beFalse         : [false, true]
      beNull          : [_(null), 1]
      beDefined       : [1, _(undefined)]
      beUndefined     : [_(undefined), 1]

    for matcher, [value, negativeValue] of cases
      # second form only - `value.should().matcher()`
      value.should()[matcher]()
      negativeValue.shouldNot()[matcher]()

  it 'mocks & stubs', ->
    class Bob
      hi: -> 'hi'
      bye: -> 'bye'
      say: (args...) -> args

    bob = new Bob()
    bob.spyOn 'hi', andReturn: 'Hello'
    bob.hi().should be: 'Hello'
    bob.hi.should().haveBeenCalled()

    bob.spyOn 'bye'
    bob.bye.shouldNot().haveBeenCalled()

    bob.spyOn 'say'
    bob.say 'I', 'am', 'Bob'
    bob.say.should().haveBeenCalledWith 'I', 'am', 'Bob'

  it "miscellaneous checks", ->
    [].should be: []
    [].shouldNot be: [2]
    ['a', 'b'].should include: 'b'
    ['a', 'b'].shouldNot include: 'c'
    {a: 1, b: 2}.should include: 'a'
    {a: 1, b: 2}.shouldNot include: 'c'

describe "Dr.Mary Control Flow helpers", ->
  it.async "should wait untill it.next called", ->
    asyncFunction = (callback) -> callback()
    asyncFunction ->
      it.next()

  it.sync "should wrap spec into Fiber", ->
    Fiber.current.shouldNot be: undefined