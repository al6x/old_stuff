require 'RubyExt/require'
require 'spec'

module RubyExt::Spec
	describe 'Array' do
		class Respond
			def test; 2 end
		end

		it "sort_by_weight" do
			a = [:a, :b, :c]
			w = [3, 2, 1]
			a.sort_by_weight(w).should == [:c, :b, :a]
			a.should == [:a, :b, :c]
			a.sort_by_weight! w
			a.should == [:c, :b, :a]
		end		
		
		it "sort_by_weight (from error)" do
			a = ["Attributes", "Micelaneous", "Containers", "Tools"]
			w = [0, 0, -1, -2]
			a.sort_by_weight! w
			a.should == ["Tools", "Containers", "Attributes", "Micelaneous"]
			w.should == [-2, -1, 0, 0]
		end
	end
end