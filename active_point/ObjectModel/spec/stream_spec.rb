require 'ObjectModel/require'
require 'spec'

module ObjectModel
	describe "ObjectModel Stream" do	
		before :each do
			CONFIG[:directory] = @dir = "#{File.dirname __FILE__}/data"
			Repository.delete :test
			@r = Repository.new :test
		end
		
		after :each do
			@r.close
			Repository.delete :test
		end
		
		it "Should revrite old Stream data if it where replaced with Simple Type (i.e. Image -> Integer)" do
			# It's too expensive to automatically do it
			# Old stream should be deleted manually or it will be deleted by garbage collector
			# And this is much safe, because if there is for example AVI, someone watch it, we can simultaneously 
			# upload a new one, and when someone finished GC deletes it.
		end
		
		it "Write & Read" do           			
			sid = @r.stream_put do |f|
				f.write "Some data"
			end			
			
			data = nil
			@r.stream_read sid do |f|
				data = f.read
			end
			data.should == "Some data"
			
			data = ""
			# The size of the Part is defined in 'config'
			@r.stream_read_each sid do |part|
				data << part
			end
			data.should == "Some data"
		end						
		
		it "Id should works properly (from error)" do
			sid = @r.stream_put do |f|
				f.write "Some data"
			end			
			
			sid2 = @r.stream_put do |f|
				f.write "Some data2"
			end			 
			
			data = nil
			@r.stream_read sid do |f|
				data = f.read
			end
			data.should == "Some data"
		end				
		
		it "collect_garbage stream" do					
			#			# GC should work (but id doesn't)
			#			GCTest.new			
			#			has = false
			#			ObjectSpace.each_object(GCTest){has = true}
			#			has.should be_true
			#			ObjectSpace.garbage_collect
			#			has = false
			#			ObjectSpace.each_object(GCTest){|o| has = true}
			#			has.should be_false			
			
			class GCStub
				class << self
					attr_accessor :objects
					def each_object klass, &b; @objects.each{|o| b.call o} end				
				end
			end
			
			sid = @r.stream_put StringIO.new("Some data")						
			@r.stream_storage.size.should == 1
			GCStub.objects = [sid]
			@r.stream_collect_garbage GCStub 		
			@r.stream_storage.size.should == 1
			sid = nil
			GCStub.objects = []
			@r.stream_collect_garbage GCStub		
			@r.stream_storage.size.should == 0
		end
		
		class StreamEntity
			inherit Entity
			
			metadata do 
				attribute :stream, :data
				attribute :streams, :object
			end
		end
		
		it "Should correct restore after loading" do			
			@r.transaction{
				e = StreamEntity.new 'e'
				e.stream = @r.stream_put "After loading"
				e.streams = [e.stream]
			}.commit
			
			@r.stream_read(@r['e'].stream).should == "After loading"			
			@r.stream_read(@r['e'].streams[0]).should == "After loading"			
		end
		
		it "Read & Write to File" do
			fname = "#{@dir}/frwtest"
			File.delete fname if File.exist? fname
			
			sid = @r.stream_put do |f|
				f.write "Some data"
			end
			
			@r.stream_read_to_file sid, fname
			
			sid2 = @r.stream_put_from_file fname
			
			data = nil
			@r.stream_read sid2 do |f|
				data = f.read
			end
			data.should == "Some data"									
			
			File.delete fname if File.exist? fname
		end
		
		#		it "Garbage collector shouldn't collect Streams that aren't managed yet, but referenced from memory" do
		#			stream = @r.put "Some data" # Referenced, but not managed yet
		#			@r.collect_garbage
		#			sleep 3
		#			stream.read.should == "Some data"
		##			# Later this stream will be added to an Object, but right now it's not managed,
		##			# and if during this time GarbageCollector will runs it should not delete it.
		##			
		##			# Later this stream will be processed further.
		##			c = @r.copy
		##			c[:stream] = stream
		##			c.commit					
		#		end
	end
end
