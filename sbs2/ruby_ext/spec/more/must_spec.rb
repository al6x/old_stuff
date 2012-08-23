require "spec_helper"

describe 'Assert' do
  it 'misc' do
    -> {must.be_never_called}.should raise_error(/must be never_called/)
    -> {nil.must_not.be_nil}.should raise_error(/must not be nil/)
    1.must_not.be_nil

    1.must.be_in 1, 2
    1.must.be_in [1, 2]
    0.must.be_in 0..1

    "".must.be_a String
    "".must.be_a String, Symbol

    2.must > 1
    2.must.be > 1

    1.must.be_defined
    -> {nil.must.be_defined}.should raise_error(/must be defined/)

    [1, 2].must.include 1
  end

  it "equality" do
    1.must.be_equal_to 1
    -> {1.must.be_equal_to 2}.should raise_error(/1 must be equal_to 2/)
    1.must.be 1
    -> {1.must.be 2}.should raise_error(/1 must be equal_to 2/)
  end

  it 'must & must_not' do
    [].must.be_empty
    [''].must_not.be_empty

    -> {[''].must.be_empty}.should raise_error(/must be/)
    -> {[].must_not.be_empty}.should raise_error(/must not be/)
  end

  it "should return result" do
    [].must.be_empty.should == []
  end

  it "have" do
    [1, 2, 3].must_not.have_any{|v| v == 4}
    -> {[1, 2, 3].must_not.have_any{|v| v == 2}}.should raise_error(/must not have any/m)
  end
end