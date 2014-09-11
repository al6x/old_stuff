require 'HashStorage/require'
require 'spec'

# Storage provides only reliable mechanism for saving data, nothing more.
# It contains no logic.

module HashStorage
	describe "Storage" do
		before :each do 
			@dir = "#{File.dirname(__FILE__)}/data"
			Storage.delete 'test', @dir
			@storage = Storage.new('test', @dir)		
		end
	
		after :each do
			@storage.close
			Storage.delete 'test', @dir
		end
		
		it "Should not allow to start two the same simultaneously" do
			s = Storage.new :same_time, @dir
			lambda do
				Storage.new :same_time, @dir
			end.should raise_error
			s.close
			Storage.delete :same_time, @dir
		end
		
		it "Should delete non existing Storage without exception" do
			Storage.delete 'non_existing_storage', @dir
		end
	
		it "clear" do
			@storage['a'] = 'b'		
			@storage['a'].should == 'b'						
			
			@storage.clear
			lambda do
				@storage['a']
			end.should raise_error(NotFound)	
		end			
	
		it "delete" do
			@storage['a'] = 'b'		
			@storage['a'].should == 'b'
				
			@storage.delete 'a'
		
			lambda do
				@storage['a']
			end.should raise_error(NotFound)	
		end	
	
		it "size" do
			@storage.size.should == 0
			@storage['key'] = 'value'
			@storage.size.should == 1
		end
	
		it "Should save and load object" do		
			@storage['key'] = 'value'
			@storage['key'].should == 'value'
		end		
		
		it "Should rewrite objects" do
			@storage['a'] = 'b'
			@storage['a'] = 'b2'
			@storage['a'].should == 'b2'
		end
		
#		it "Read, Write & Delete should be synchronized" do
#			data = File.read(__FILE__)
#			@storage["key"] = data
#					
#			Thread.new do
#				100.times do
#					@storage["key"] = data
#				end
#			end
#					
#			Thread.new do
#				100.times do
#					@storage.delete "key"
#				end
#			end
#					
#			Thread.new do
#				100.times do
#					value = nil
#					begin
#						value = @storage["key"]
#					rescue Exception
#					end
#					((value == nil) or (value == data)).should be_true
#				end
#			end
#		end
	
#		it "atomic_write should be atomic during exception" do
#			@storage['key1'] = 'before'
#			begin
#				@storage.atomic_write(
#					'key1' => 'value1',
#					"" => "", # will cause exception during writing
#					'key2' => 'value2'
#				)
#			rescue; end
#
#			@storage['key1'].should == 'before'
#			@storage.size.should == 1
#		end
	
		it "Should return set of all og_id" do
			@storage.list_of_ids.should be_empty
			@storage['key'] = 'value'
			@storage.list_of_ids.size.should == 1
			@storage.list_of_ids[0].should == 'key'
		end
	end
end

















