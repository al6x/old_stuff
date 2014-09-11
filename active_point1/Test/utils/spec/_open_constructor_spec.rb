require 'spec'
require 'utils/open_constructor'

module OpenConstructorSpec
	class Test
		include Utils::OpenConstructor
		attr_accessor :name, :value
    end
	
	describe 'OpenConstructor' do
		it 'should initialize atributes' do
			t = Test.new.set(:name => 'name', :value => 'value')
			[t.name, t.value].should == ['name', 'value']
		end
	end
end