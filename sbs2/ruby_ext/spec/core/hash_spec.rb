require "spec_helper"

describe 'Hash' do
  it 'should symbolize hashes in arbitrary objects' do
    as_string = {
      'a'   => 'a',
      'b'   => {
        'a' => [{'a' => 'a'}]
      }
    }
    as_symbol = {
      a: 'a',
      b: {
        a: [{a: 'a'}]
      }
    }

    Hash.symbolize(as_string).should == as_symbol
    Hash.stringify(as_symbol).should == as_string
  end
end