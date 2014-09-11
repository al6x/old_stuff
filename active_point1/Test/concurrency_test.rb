require 'monitor'

def p m
	@mon = Monitor.new
	@mon.synchronize{print(m+"\n")}
end

class Synchronizer
	def initialize
		@writer, @readers = nil, {}
		@monitor = Monitor.new
		@condition = @monitor.new_cond				
    end			
	
	def synchronize mode, &block
		if mode == :EX
			begin
				write_start
				block.call
			ensure
				write_stop
            end
		elsif mode == :SH
			begin
				read_start
				block.call
			ensure
				read_stop
            end			
		else
			raise "Unknown mode!"
        end
    end
	
	protected
	def read_start				
		@monitor.synchronize do
			@condition.wait_while do
#				p "In read  #{@readers.inspect} | #{@writers.inspect} | #{Thread.current}";
				@writer
			end
#			p '- read_start'
			if @readers.include?(Thread.current)
				@readers[Thread.current] += 1
			else
				@readers[Thread.current] = 1
            end
		end
    end
	
	def read_stop					
		@monitor.synchronize do
#			p '- read_stop'			
			if @readers[Thread.current] and @readers[Thread.current] > 1
				@readers[Thread.current] -= 1
			elsif @readers[Thread.current]
				@readers.delete Thread.current
            end
			@condition.signal
		end
    end
	
	def write_start				
		@monitor.synchronize do
			@readers.delete Thread.current
			@condition.signal
			
			@condition.wait_until do
#				p "In write  #{@readers.inspect} | #{@writers.inspect} | #{Thread.current}";
				!@writer and @readers.empty?
            end
#			p '- write_start'
			@writer = Thread.current
		end
    end
	
	def write_stop			
		@monitor.synchronize do
#			p '- write_stop'
			@writer = nil
			@condition.signal
		end
    end
end

#require 'sync'
#
#class SyncImpl
#	include Sync_m	
#	
#	def read_start
#		sync_lock :SH
#    end
#	
#	def read_stop
#		sync_unlock :SH
#    end
#	
#	def write_start
#		sync_lock :SH
#		sync_lock :EX
#    end
#	
#	def write_stop
#		sync_unlock :EX
#		sync_unlock :SH
#    end
#end
#
#SharedResource = SyncImpl

class Timeline	
	
	def initialize 
		@msg = ""
		@time = Time.new()
		@space = -1
    end
	
	def time								
		t = (Time.new - @time).to_s.split('.')[0].to_i
		#		@msg += t.to_s
		if t - @space > 0
			(t-1-@space).times{@msg += " "}
			@msg += t.to_s
		end
		@space = t
    end
	
	def to_s; @msg end
end

res = Synchronizer.new
Thread.abort_on_exception=true

r1, r2, w1, w2 = Timeline.new, Timeline.new, Timeline.new, Timeline.new

t1 = Thread.new do
	r1.time
	p "r1.start #{r1.time}"
	res.synchronize(:SH) do
		r1.time
		p "r1.run #{r1.time}"
		sleep 3
		r1.time
		p "r1.done #{r1.time}"
	end
	r1.time
	p "r1.out #{r1.time}"
end

t2 = Thread.new do
	r2.time
	p "r2.start #{r2.time}"
	res.synchronize(:SH) do
		r2.time
		p "r2.run #{r2.time}"
		sleep 1
		r2.time
		p "r2.done #{r2.time}"
	end
	r2.time
	p "r2.out #{r2.time}"
end

sleep 2

t3 = Thread.new do
	w1.time
	p "w1.start #{w1.time}"
	res.synchronize(:SH) do
		res.synchronize(:EX) do
			w1.time
			p "w1.run #{w1.time}"
			sleep 2
			w1.time
			p "w1.done #{w1.time}"
		end
	end
	w1.time
	p "w1.out #{w1.time}"
end

sleep 2

t4 = Thread.new do
	w2.time
	p "w2.start #{w2.time}"
	res.synchronize(:SH) do
		res.synchronize(:EX) do
			w2.time
			p "w2.run #{w2.time}"
			sleep 3
			w2.time
			p "w2.done #{w2.time}"
		end
	end
	w2.time
	p "w2.out #{w2.time}"
end

sleep 3

t5 = Thread.new do
	r1.time
	res.synchronize(:SH) do
		r1.time
		sleep 1
		r1.time
	end
	r1.time
end

sleep 5

puts w2
puts w1
puts r2
puts r1

puts "t1 #{t1}, t2 #{t2}, t3 #{t3}, t4 #{t4}, t5 #{t5}"



	
	
	
	
	
	
	
	
	
	
	
	