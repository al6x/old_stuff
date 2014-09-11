require 'RubyExt/require'
require 'spec'

module RubyExt::Spec
	describe 'Assert' do
		it do
			lambda{should! :be_never_called}.should raise_error(/ever/)
			lambda{nil.should_not! :be_nil}.should raise_error(/nil/)
			1.should_not! :be_nil
			1.should! :==, 1
			lambda{1.should! :==, 2}.should raise_error(/==/)
			1.should! :be_in, [1, 2]
			"".should! :be_a, String
			String.should! :be, String			
			1.should! :<, 2
		end		
	end
end