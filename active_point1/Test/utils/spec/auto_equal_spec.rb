require 'spec'
require 'utils/auto_equal'

describe 'AutoEqual' do
	class AB
		attr_accessor :a, :b
		include AutoEqual
		def initialize a, b
			@a, @b = a, b
		end
	end
	
	class BA		
		def initialize b, a
			@b, @a = b, a
		end
	end
	
	it "Order of variables" do
		ab = AB.new 1, 2
		ba = BA.new 2, 1
		ab.should == ba
		ab.should_not.eql? ba
	end
	
	it "Same class different values" do
		ab = AB.new 1, 2
		ab2 = AB.new 1, nil		
		ab.should_not == ab2
	end
	
	it "Complex structures" do
		a = AB.new 1, 2
		b = AB.new 1, a
		
		c = AB.new 1, 2
		d = AB.new 1, c
		
		b.should == d
		b.should.eql? d
		b.hash.should == d.hash
		
		c.a = 2
		
		b.should_not == d
		b.should_not.eql? d
		b.hash.should_not == d.hash
	end
	
	#	it "Cycle reference" do
	#		a = AB.new 1, 2
	#		b = AB.new 1, a
	#		a.b = b
	#
	#		c = AB.new 1, 2
	#		d = AB.new 1, c
	#		c.b = d
	#
	#		b.should == d
	#		b.should.eql? d
	#		b.hash.should == d.hash
	#    end
	
	it 'hash' do
		ab = AB.new 1, 2
		ab2 = AB.new 1, 2	
		ab3 = AB.new 1, nil
		ab.hash.should == ab2.hash
		ab.hash.should_not == ab3.hash
	end
end