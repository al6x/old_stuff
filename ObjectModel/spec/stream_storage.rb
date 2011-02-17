require 'ObjectModel/require'
require 'spec'

module ObjectModel
	describe "StreamStorage" do
		def before
			@dir = "#{File.dirname(__FILE__)}/data"
			Repository::StreamStorage.delete 'test', @dir
			@storage = Repository::StreamStorage.new('test', @dir)
		end
		
		def after
			Repository::StreamStorage.delete 'test', @dir
		end		
		
		it "Onestep Save & stream_read operations" do		
			before
			data = "Some binary data"
			@storage.stream_put 1, data
			
			@storage.stream_read(1).should == data		
			@storage.stream_size(1).should == "Some binary data".size
			
			s = ""
			@storage.stream_read_each 1 do |part|
				s << part
			end
			s.should == data
			after
		end
		
		it "clear" do			
			before
			@storage.stream_put 1, 'b'						
			
			@storage.clear
			lambda do
				@storage.stream_read 1
				end.should raise_error	
				after
			end
			
			it "size" do
				before
				@storage.size.should == 0
				@storage.stream_put 1, "Some binary data"
				@storage.size.should == 1
				after
			end
			
			it "Save & stream_read operations" do		
				before
				data = "Some binary data"
				@storage.stream_put 1 do |f|
					f.write data
				end
				
				stream_readed = ""
				@storage.stream_read 1 do |f|
					while c = f.read(1)
						stream_readed << c
					end
				end
				stream_readed.should == data
				after
			end
			
			it "stream_put_each" do		
				before
				data = "Some binary data"
				stream = StringIO.new data
				@storage.stream_put_each 3, stream
				
				@storage.stream_read(3).should == data
				sleep 0.5
				after
			end
			
			it "Should return NotFound, if stream not found" do
				before
				lambda{@storage.stream_read 'invalid stream id'}.should raise_error
				after
			end
			
			it "Should allow stream_read the same Stream simultaneously" do
				before
				@storage.stream_put 1, "Some data"
				
				timeline = mock("Timeline")
				timeline.should_receive(:first_stream_readed).ordered
				timeline.should_receive(:second_stream_readed).ordered
				timeline.should_receive(:second_finished).ordered
				timeline.should_receive(:first_finished).ordered
				
				t1 = Thread.new do
					buff1 = ""
					@storage.stream_read 1 do |f|
						buff1 << f.read(2)
						timeline.first_stream_readed
						sleep 2
						buff1 << f.read(10)
						timeline.first_finished
					end				
				"1#{buff1}".should == "1Some data"				
				end
				
				t2 = Thread.new do
					buff2 = ""
					@storage.stream_read 1 do |f2|
						buff2 << f2.read(2)
						timeline.second_stream_readed
						sleep 1
						buff2 << f2.read(10)
						timeline.second_finished
					end
				"2#{buff2}".should == "2Some data"
				end
				
				t2.join; t1.join
				after
			end		
			
			it "Should raise error if Stream has been deleted" do
				before
				@storage.stream_put 1, "Some data"
				@storage.delete 1
				lambda{@storage.stream_read 1}.should \
				raise_error(RuntimeError, /The Stream with id '1' has been deleted!/)
				after
			end
			
			it "Should return list of all stream_id" do
				before
				@storage.list_of_ids.should be_empty
				@storage.stream_put 1, 'Some data'
				@storage.list_of_ids.size.should == 1
				@storage.list_of_ids[0].should == '1'
				after
			end		
			
			it "Should save metadata" do
				before
				@storage.metadata_put 1, :a => :b
				@storage.metadata_read(1).should == {:a => :b}
				after
			end
		end
	end
