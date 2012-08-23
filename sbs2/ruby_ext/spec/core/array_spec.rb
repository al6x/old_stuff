require "spec_helper"

describe 'Array' do
  it 'sfilter' do
    %w{alpha betta gamma}.sfilter('lpha', /et/).should == ['gamma']
  end
end