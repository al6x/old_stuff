require 'WGUI/require'
require 'spec'

module WGUI
	module Core
		describe "WigetContainer" do						
			it "Should find not explicitly defined children (from error)" do								
				c = WComponent.new
				c.instance_variable_set "@child", Wiget.new
				list = []
				c.each_child{|c| list << c}
				list.size.should == 1
			end
			
			it "Error, displays child twice (from error)" do
				class View < WComponent
					attr_accessor :root
					children :root
					
					def initialize
						super												
					end								
				end
				
				class View2 < View; end
				
				v = View2.new
				v.root = Wiget.new
				list = []
				v.each_child{|c| list << c}
				list.size.should == 1
			end						
			
			it "Should correct works with children" do
				class A < Wiget
					include WigetContainer
					children :a
					
					def a; 'a' end
				end
				
				class B < A
				end
				
				class C < B
					children :@c
					
					def initialize
						@c = 'c'
					end
				end
				
				a = []
				A.new.each_child{|c| a << c}
				a.should == ['a']
				
				a = []
				B.new.each_child{|c| a << c}
				a.should == ['a']
				
				a = []
				C.children_as_methods.should == [:a]
				C.children_as_variables.should == ["@c"]
				C.new.each_child{|c| a << c}
				a.sort.should == ['a', 'c']
			end							
			
			it "Should have only one '@edit'" do
				class Property < WComponent
					children :@editor
				end
				
				class PString < Property    
					def initialize
						@editor = WLabel.new "value"
					end
				end
				
				l = []
				PString.new.each_child{|c| l << c}
				l.size.should == 1 # 
			end
		end
	end
end
