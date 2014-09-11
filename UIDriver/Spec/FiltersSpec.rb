require "UIDriver/Client/require"
require "spec"

module UIDRiver			
	
	describe "Filters" do					
		before :each do @b = UIDriver::Client::Browser.new("localhost:7000") end
		after :each do @b.close end		
		
		it "Coordinates Check" do
			@b.go "filters/coordinates_check"
			@b.single("//div[contains(@class, 'item')]").first.to_a.should == [15, 25, 40, 50]
		end
		
		it "Left, Top, Bottom, Center" do
			@b.go "filters/left_top_right_bottom"
			list = @b.list("//td[@class='item']")
			list.size.should == 5
			
			list.filter(:left).text.should == "Left"
			list.filter(:top).text.should == "Top"
			list.filter(:right).text.should == "Right"
			list.filter(:bottom).text.should == "Bottom"
			
			list.filter(:center_x).size.should == 3
			list.filter(:center_y).size.should == 3
			list.filter(:center).text.should == "Center"
		end
		
		it "inside" do
			@b.go "filters/inside"
			scope = @b.single("//*[@list='scope']")
			items = @b.list("//*[@list='item']")
			items.size.should == 2
			
			items.filter(:inside, scope).text.should == "Inside"
		end
		
		it "inverse" do
			@b.go "filters/inside"
			scope = @b.single("//*[@list='scope']")
			items = @b.list("//*[@list='item']")
			items.size.should == 2
			
			items.inverse_filter(:inside, scope).text.should == "Outside"			
		end
		
		it "near" do
			@b.go "filters/left_top_right_bottom"
			top = @b.single "//*[@list='top']"
			list = @b.list "//*[@list='center' or @list='bottom']"
			list.size.should == 2
			
			list.filter(:near, top).text.should == "Center"
		end
		
		it "left_of, right_of, top_of, bottom_of" do
			@b.go "filters/left_top_right_bottom_with_noise"
			
			center = @b.single "//*[@list='center']"			
			list = @b.list("//td[@class='item']")
			list.size.should == 9
			
			list.filter(:left_of, center).text.should == "Left"
			list.filter(:top_of, center).text.should == "Top"
			list.filter(:right_of, center).text.should == "Right"
			list.filter(:bottom_of, center).text.should == "Bottom"
		end
		
		it "near" do
			@b.go "filters/left_top_right_bottom"
			
			top = @b.single "//*[@list='top']"
			list = @b.list "//*[@list='center' or @list='bottom']"
			list.size.should == 2
			
			list.filter(:near, top).text.should == "Center"
		end
		
		it "cell" do
			@b.go "filters/table"
			
			col = @b.single "//*[@list='b']"
			row = @b.single "//*[@list='2']"			
			list = @b.list "//*[@class='item']"
			list.size.should == 16
			
			list.filter(:cell, col, row).text.should == "b2"
		end
		
		it "should not find Cell outside of Column and Row" do
			@b.go "filters/table2"
			
			col = @b.single "//*[@list='b']"
			row = @b.single "//*[@list='2']"			
			list = @b.list "//*[@class='item']"
			list.size.should == 15
			
			list.filter(:cell, col, row).size.should == 0
		end
	end		
end		