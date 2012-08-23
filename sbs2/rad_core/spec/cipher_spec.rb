require 'spec_helper'

describe "Cipher" do
  before do
    @cipher = Rad::Cipher.new 'secret secret secret secret secret secret'
  end

  it 'hmac' do
    @cipher.hmac('data').should_not be_nil
  end

  it "sign & unsign" do
    signed_data = @cipher.sign 'data'
    signed_data.should =~ /^data/

    @cipher.unsign(signed_data).should == 'data'
    -> {Rad::Cipher.new('invalid').unsign(signed_data)}.should raise_error(/invalid signature/)
  end

  it "encode & decode" do
    encrypted_data = @cipher.encrypt 'data'
    encrypted_data.should_not =~ /^data/

    @cipher.decrypt(encrypted_data).should == 'data'
    another_sipher = Rad::Cipher.new('invalid invalid invalid invalid invalid invalid')
    -> {another_sipher.decrypt(encrypted_data)}.should raise_error(/invalid encryption/)
  end
end