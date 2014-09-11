require 'RubyExt/require_base'
require 'spec'

module RubyExt::Spec
	describe 'OpenConstructor' do
		class Test
			include OpenConstructor
			attr_accessor :name, :value
    end

		it 'should initialize atributes from Hash' do
			t = Test.new.set(:name => 'name', :value => 'value')
			[t.name, t.value].should == ['name', 'value']
		end
		
		it 'should initialize atributes from any Object' do
			t = Test.new.set(:name => 'name', :value => 'value')
			t2 = Test.new.set t
			[t2.name, t2.value].should == ['name', 'value']
		end
		
		it 'restrict copied values' do
			t = Test.new.set(:name => 'name', :value => 'value')
			t2 = Test.new.set t, [:name]
			[t2.name, t2.value].should == ['name', nil]
			
			t = {:name => 'name', :value => 'value'}
			t2 = Test.new.set t, [:name]
			[t2.name, t2.value].should == ['name', nil]
		end
		
		it 'to_hash' do
			h = {:name => 'name', :value => 'value'}
			t = Test.new.set h
			t.to_hash.should == h
		end
	end
end