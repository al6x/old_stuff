require "spec_helper"

describe "Miscellaneous" do
  describe "ARGV parsing" do
    it 'basics' do
      {
        %(:a a 'a' 2 3.4 /a/)   => [:a, 'a', 'a', 2, 3.4, /a/, {}],
        %(a, b)                 => ['a', 'b', {}],
        %(k: v)                 => [{k: 'v'}],
        %(k: v, k2: 2, k3: nil) => [{k: 'v', k2: 2, k3: nil}]
      }.each do |input, result|
        RubyExt.argv(input.split(/\s/)).should == result
      end
    end
  end
end