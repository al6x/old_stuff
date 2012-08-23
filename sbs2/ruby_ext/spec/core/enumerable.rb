require "spec_helper"

describe 'Enumerable' do
  it 'every' do
    list = %w{alpha betta gamma}
    list.every.upcase!
    list.should == %w{ALPHA BETTA GAMMA}
  end
end