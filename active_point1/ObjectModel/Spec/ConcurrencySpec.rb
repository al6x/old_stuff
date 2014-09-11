require 'ObjectModel/require'
require 'spec'
require "#{File.dirname(__FILE__)}/timer"

module ObjectModel
	module ConcurrencySpec
		describe "Concurrency" do	
			class SimpleEntity
				inherit Entity
				metadata do
					attribute :name, :string
					attribute :value, :number
				end
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
			
			it "Should raise Error if update is outdated" do		
				@r.transaction{
					SimpleEntity.new 'one'
				}.commit
				
				t1 = Thread.new do
					lambda{					
						tr = @r.transaction{
							@r['one'].name = "name one"
						}
						sleep 0.5
						tr.commit							
					}.should raise_error(OutdatedError)
				end		
								
				t2 = Thread.new do				
					@r.transaction{
						@r['one'].name = "name two"
					}.commit					
				end
				t1.join; t2.join
				@r['one'].name.should == "name two"			
			end
			
			it "General concurrency test" do
				@r.transaction{
					from = SimpleEntity.new 'from'
					from.value = 5
					to = SimpleEntity.new 'to'
					to.value = 0
				}.commit
				
				threads = []
				20.times do
					threads << Thread.new do
						catch :done do
							while true do					
								@r.isolate do																												
									throw :done if @r['from'].value <= 0							
									
									sleep(rand(10) / 1000.0)								
									
									begin
										@r.transaction{
											@r['from'].value -= 1
											@r['to'].value += 1																
										}.commit
									rescue OutdatedError
										next
									end	
								end
							end					
						end
					end
				end
				threads.each{|t| t.join}
				
				@r['from'].value.should == 0
				@r['to'].value.should == 5
			end		
			
#			# There are 2 read_streamers and 2 put_streamrs, read_streamers should works in parallel, put_streamrs exclusivelly
#			#                            
#			#         4x5-----8         put_streamr 2
#			#     2x3---5               put_streamr 1
#			# 0-1                       read_streamer 2
#			# 0-----3       7x8-9       read_streamer 1  
#			# 0 1 2 3 4 5 6 7 8 9       timeline
#			# 
#			it "'read' operations should works in parallel and 'write' exclusivelly" do
#				copy = @r.copy
#				copy[:first] = SimpleEntity.new :first
#				copy[:second] = SimpleEntity.new :second
#				@r.commit
#				
#				timer = Timer.new
#				r1 = mock("read 1")
#				r1.should_receive(:created).with(0)
#				r1.should_receive(:start).with(0)
#				r1.should_receive(:finish).with(3)						
#				Thread.new do
#					r1.created timer.time
#					@r.isolate do
#						r1.start timer.time
#						@r[:first]
#						sleep 3
#						@r[:second]
#						r1.finish timer.time
#					end
#				end
#				
#				r2 = mock("read 2")
#				r2.should_receive(:created).with(0)
#				r2.should_receive(:start).with(0)
#				r2.should_receive(:finish).with(1)						
#				Thread.new do			
#					r2.created timer.time
#					@r.isolate do
#						r2.start timer.time
#						@r[:first]
#						sleep 1
#						@r[:second]
#						r2.finish timer.time
#					end
#				end
#				
#				sleep 2
#				
#				w1 = mock("write 1")
#				w1.should_receive(:created).with(2)
#				w1.should_receive(:start).with(3)
#				w1.should_receive(:finish).with(5)						
#				Thread.new do							
#					w1.created timer.time									
#					@r.isolate do									
#						copy = @r[:first].copy
#						copy.value = 'new value'
#						@r.om_engine.engine_commit_debug(2){w1.start timer.time}	# Should sleep for 2 sec
#						w1.finish timer.time
#					end
#				end
#				
#				sleep 2
#				
#				w2 = mock("write 2")
#				w2.should_receive(:created).with(4)
#				w2.should_receive(:start).with(5)
#				w2.should_receive(:finish).with(8)						
#				Thread.new do
#					w2.created timer.time
#					@r.isolate do					
#						copy = @r[:first].copy
#						copy.value = "new value 2"
#						@r.om_engine.engine_commit_debug(3){w2.start timer.time;} # Should sleep for 2 sec
#						w2.finish timer.time
#					end
#				end
#				
#				sleep 3
#				
#				r11 = mock("put_streamr 2")
#				r11.should_receive(:created).with(7)
#				r11.should_receive(:start).with(8)
#				r11.should_receive(:finish).with(9)						
#				t = Thread.new do
#					r11.created timer.time
#					@r.isolate do
#						r11.start timer.time
#						@r[:first]
#						sleep 1
#						@r[:second]
#						r11.finish timer.time
#					end
#				end	
#				t.join
#			end			
		end
	end
end