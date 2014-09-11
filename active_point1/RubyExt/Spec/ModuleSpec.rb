require 'RubyExt/require_base'
require 'spec'

module RubyExt
	module Spec
		describe "Module" do
			class A
				class B
					class C
						
					end
				end
			end
			
			it "Namespace" do
				File.namespace.should == nil
				A::B::C.namespace.should == RubyExt::Spec::A::B
			end
			
			class AnonymousClass
				class << self
					def anonymous_name
						self.name
					end
				end
			end
			
			
			it "name" do
				A::B::C.name.should == "RubyExt::Spec::A::B::C"
			end
			
			class X; end
			class Y < X; end
			class Z < Y; end
			
			
			it "each_ancestor" do
				list = []
				Z.each_ancestor{|a| list << a}
				list.should include Y
				list.should include X
				list.should_not include Z
				list.should_not include Object
				list.should_not include Kernel
				
				list = []
				Z.each_ancestor(true){|a| list << a}
				list.should include Y
				list.should include X
				list.should_not include Z
				list.should include Object
				list.should include Kernel
			end
			
			it "each_namespace" do
				list = []
				A::B::C.each_namespace{|n| list << n}
				list.should == [RubyExt::Spec::A::B, RubyExt::Spec::A, RubyExt::Spec, RubyExt]
			end
			
			it "is?" do
				File.is?(IO).should be_true
			end
			
			class WrapMethod
				def method_name value
					10*value
				end
			end
			
			it "wrap_method" do
				WrapMethod.wrap_method :method_name do |old, value|
					send(old, value)*value
				end
				WrapMethod.new.method_name(10).should == 1000
			end
			
			it "resources" do
				ForModule::NS1::B["data"].should == "A.data"
				ForModule::NS1::B2["data"].should == "NS1.data"
			end
			
			it "resources, should aslo inherit resources from included modules" do
				ForModule::NS2::B["data"].should == "M.data"
			end
			
			module M
				def m_m; end				
				module ClassMethods
					def cm_m; end
				end
			end						
			
			class C
				inherit M
			end
			
			it "inherit" do
				C.respond_to?(:cm_m).should be_true
				C.new.respond_to?(:m_m).should be_true				
			end
			
			module M2
				include M
				
				module ClassMethods
					def cm2_m; end
				end
			end
			
			class D
				inherit M2
			end
			
			it "should inherit all ancestors class methods" do
				D.respond_to?(:cm_m).should be_true
				D.respond_to?(:cm2_m).should be_true
				D.new.respond_to?(:m_m).should be_true
			end
			
			class C2
				inherit M
			end
			
			it "Shouldn't redefine ancestors class methods" do
				C2.respond_to?(:cm2_m).should be_false
		end
		end
	end
end
