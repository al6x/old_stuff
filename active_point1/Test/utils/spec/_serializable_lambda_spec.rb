require 'utils/serializable_lambda'
require 'spec'

module Utils
	describe 'SerializableLambda' do
		it "Single line" do
			code = "{|v| v*2}"
			proc = lambdas code
			proc.call(2).should == 4
			SerializableLambda.get_source(proc).should == code
        end
		
		it "Multiple lines" do
			code = "\
do |v| 
	v*2
end"
			proc = lambdas code
			proc.call(2).should == 4
			SerializableLambda.get_source(proc).should == code
        end
		
		it "Exception" do
			lambda do
				SerializableLambda.get_source(lambda{2})
			end.should raise_error
        end
    end
end
