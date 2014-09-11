require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module Spec
		module AspectSpec
			describe "AspectSpec" do
				class BaseClass
					inherit Entity
					metadata do
						attribute :base, :string
					end
				end
				
				module AspectClass
					inherit Entity
					metadata do
						attribute :aspect, :string
					end
				end
				
				
				class ChildClass < BaseClass
					inherit AspectClass
					
					metadata do
						attribute :child, :string
					end
				end
				
				it "Aspect" do								
					ChildClass.meta.attributes.keys.to_set.should == [:aspect, :child, :base].to_set
				end
				
				it "Should be properly initialized" do					
					@r.transaction{
						c = ChildClass.new
						c.base.should == ""
						c.aspect.should == ""
						c.child.should == ""
					}					
				end

				before :each do
					ObjectModel::CONFIG[:directory] = "#{File.dirname __FILE__}/data"					
					Repository.delete :test
					@r = Repository.new :test
				end
				
				after :each do
					@r.close
					Repository.delete :test
				end
			end
		end
	end
end