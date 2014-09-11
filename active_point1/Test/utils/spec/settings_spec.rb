require 'spec'
require 'utils/settings'
require 'singleton'

describe "Settings" do
	class SettingsSpec < Utils::Settings
		include Singleton
		def initialize 
			super 'utils/spec/settings_spec.xml'
		end
    end
	
	it "Usage" do
		lambda{
			SettingSpec.new
        }.should raise_error
		
		s = SettingsSpec.instance
		s.string.should == 'a string'		
		s.string.is_a?(String).should be_true
		
		s.integer.should == 2
		s.integer!.should == 2
		s.integer.is_a?(Integer).should be_true
		s.integer!.is_a?(Integer).should be_true
		
		s.float.should == 2.2
		s.float.is_a?(Float).should be_true
		
		s.boolean.should == true
		s.boolean.is_a?(TrueClass).should be_true
		
		s.node.value.should == 'value'
		
		lambda{
			s.invalid!
        }.should raise_error("Undefined value of the 'config.invalid' in the 'utils/spec/settings_spec.xml' file!")
		
		lambda{
			s.node.invalid!
        }.should raise_error("Undefined value of the 'config.node.invalid' in the 'utils/spec/settings_spec.xml' file!")
		
		s.invalid.should == nil
		s.node.invalid.should == nil
    end
end