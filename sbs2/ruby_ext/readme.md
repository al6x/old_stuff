## must - assertion tool, kind of RSpec assertions in runtime code

Expectations are generated dynamically, so it will be also available and have the same form
for any of Your custom methods.

It also doesn't pollute core Ruby classes very much, there are only 2 methods `must`, `must_not` added to
the `Object` class.

``` ruby
1.must.be_in 1..2
'a'.must.be_in 'a', 'b', 'c'
'a'.must.be_a String
'value'.must_not.be_nil
2.must.be > 1
[].must.be_empty
[1, 2, 3].must_not.have_any{|v| v == 4}
```

## inherit - multiple inheritance in Ruby
Do you remember this `def self.included(base) ... end` You don't need it anymore.

``` ruby
module Feature
  def cool_method; end
  class_methods do
    def cool_class_method; end
  end
end

class TheClass
  inherit Feature
end

TheClass.new.cool_method
TheClass.cool_class_method
```

## cache_method

``` ruby
def complex_calculation
  2 * 2
end
cache_method :complex_calculation
```

## OpenConstructor - adds mass assignment to any class

``` ruby
class TheClass
  include RubyExt::OpenConstructor
  attr_accessor :a, :b
end

o = TheClass.new.set a: 'a', b: 'b'
o.a => 'a'
o.to_hash => {a: 'a', b: 'b'}
```

## Callbacks

[TODO add desctiption]

# Usage

``` bash
gem install ruby_ext
```

``` ruby
require 'ruby_ext'
```

## License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.