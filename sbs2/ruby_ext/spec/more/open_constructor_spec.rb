require "spec_helper"

describe 'OpenConstructor' do
  before_all do
    class Tmp
      include RubyExt::OpenConstructor
      attr_accessor :name, :value
    end
  end
  after_all{remove_constants :Tmp}

  it 'should initialize atributes from Hash' do
    t = Tmp.new.set(name: 'name', value: 'value')
    [t.name, t.value].should == ['name', 'value']
  end

  it 'should initialize atributes from any Object' do
    t = Tmp.new.set(name: 'name', value: 'value')
    t2 = Tmp.new.set t
    [t2.name, t2.value].should == ['name', 'value']
  end

  it 'restrict copied values' do
    t = Tmp.new.set(name: 'name', value: 'value')
    t2 = Tmp.new.set t, [:name]
    [t2.name, t2.value].should == ['name', nil]

    t = {name: 'name', value: 'value'}
    t2 = Tmp.new.set t, [:name]
    [t2.name, t2.value].should == ['name', nil]
  end

  it 'to_hash' do
    h = {name: 'name', value: 'value'}
    t = Tmp.new.set h
    t.to_hash.should == h
  end
end