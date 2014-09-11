require 'RubyExt/require'
require 'spec'

module RubyExt::Spec
	describe 'Kernel' do
		class Respond
			def test; 2 end
		end

		it "respond_to" do
			r = Respond.new
			r.respond_to(:not_exist).should be_nil
			r.respond_to(:test).should == 2
		end		

		it "raise_without_self" do
			begin
				ForKernel::RaiseWithoutSelf.new.test
			rescue RuntimeError => e
				stack = e.backtrace
				stack.any?{|line| line =~ /RaiseWithoutSelf/}.should be_false
				stack.any?{|line| line =~ /KernelSpec/}.should be_true
			end
		end
		
		it "raise_without_self" do
			begin
				t1 = ForKernel::RaiseWithoutSelf.new
				ForKernel::Raise2.new.test t1
			rescue RuntimeError => e
				stack = e.backtrace
				stack.any?{|line| line =~ /RaiseWithoutSelf/}.should be_false
				stack.any?{|line| line =~ /Raise2/}.should be_false
				stack.any?{|line| line =~ /KernelSpec/}.should be_true
			end
		end
	end
end