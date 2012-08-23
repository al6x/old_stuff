# encoding: utf-8
shared_examples_for 'text processor' do
  it "should not raise error on empty string" do
    @processor.call('', {}).should == ''
  end

  it "should works with unicode" do
    @processor.call('Юникод', {}).should == 'Юникод'
  end
end