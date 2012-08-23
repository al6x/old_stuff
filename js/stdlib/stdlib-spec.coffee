require 'stdlib'
require 'mary'

describe "stdlib", ->
  it "should pass smoke test", ->
    [1, 2].first().should be: 1
    [1, 2].reduce(((memo, num) -> memo + num), 0).should be: 3
    ({a: 2}.extend {b: 3}).should be: {a: 2, b: 3}