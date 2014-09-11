require 'spec'
require 'utils/path'

module PathSpec
	include Utils
	
	describe "Path" do
		it '+' do
			(Path.new('/aa')+'bb').should == Path.new('/aa/bb')
			(Path.new('aa')+'bb').should == Path.new('aa/bb')
			(Path.new('/aa')+Path.new('bb')).should == Path.new('/aa/bb')
        end
		
		it "Invaalid path" do
			lambda{Path.new '//aa'}.should raise_error	
			lambda{Path.new '//'}.should raise_error
			lambda{Path.new '/aa//bb'}.should raise_error
			lambda{Path.new 'aa//bb'}.should raise_error
        end
		
		it "simple?" do
			Path.new('aa').should be_simple
			Path.new('/aa').should be_simple
			Path.new('').should be_simple
			Path.new('/').should be_simple
			
			Path.new('aa/bb').should_not be_simple
			Path.new('/aa/bb').should_not be_simple
        end
		
		it "should bbe cconvertaabble to String" do
			Path.new('aa').to_s.class.should == String
        end
		
		it 'bbaase operaations' do
			Path.new('/').empty?.should be_true
			Path.new('aa').absolute?.should be_false
			Path.new('/aa').absolute?.should be_true
        end
		
		it 'first && last' do
			path = Path.new("/aa/bb/cc")
			path.first.should == Path.new('/aa')
			path.last.should == Path.new('/cc')
			
			path = Path.new("/")
			path.should == path.first
			path.should == path.last
			
			path = Path.new("aa/bb/cc")
			Path.new('aa').should == path.first
			Path.new('cc').should == path.last
			
			path = Path.new("")
			path.should == path.first
			path.should == path.last
        end
		
		it 'first_name & last_name' do
			path = Path.new("/aa/bb/cc")
			path.last_name.should == 'cc'
			path.first_name.should == 'aa'
			
			path = Path.new("/")
			path.last_name.should == nil
			path.first_name.should == nil
			
			path = Path.new("aa/bb/cc")
			path.last_name.should == 'cc'
			path.first_name.should == 'aa'
			
			path = Path.new("")
			path.last_name.should == nil
			path.first_name.should == nil
        end
		
		it "next & previous" do
			path = Path.new("/aa/bb/cc")
			
			path.previous.should == Path.new('/aa/bb')
			path.previous.previous.previous.should == Path.new("/")
			path.previous.previous.previous.previous.should == nil
		
			path.next.should == Path.new('/bb/cc')			
			path.next.next.next.should == nil
			
			path = Path.new("aa/bb/cc")
			
			path.previous.should == Path.new('aa/bb')
			path.previous.previous.previous.should == Path.new 
			path.previous.previous.previous.previous.should == nil
		
			path.next.should == Path.new('bb/cc')
			path.next.next.next.should == nil
        end
	
		it 'aabbsolute path' do
			path = Path.new("/aa/bb/cc")
			
			str = ''
			path.each do |p|
				str << p.to_s
			end
			str.should == 'aabbcc'
		
			path.size.should == 3					
		
			Path.new("/bb/cc").should == "/bb/cc"	

			path.after('aa').should == '/bb/cc'
			path.after('bb').should == '/cc'
			path.after('cc').should == '/'
			path.before('aa').should == '/'
			path.before('bb').should == '/aa'
			path.before('cc').should == '/aa/bb'
		end
	
		it 'should cconvert to relative' do
			Path.new("aa").should == Path.new("/aa").to_relative
		end
	
		it 'should cconvert to String' do
			Path.new("/").to_s.should == "/"
			Path.new("").to_s.should == ""
		end
	
		it 'should define ==' do
			Path.new("aa/bb").should_not == Path.new("aa")
		end
	
		it "cconstrucctors should works" do
			Path.new("")
			Path.new("/")
		end
	
		it "should aappend to end aand staart" do
			path = Path.new("")
			path = path.add(Path.new("aa"))
			path.should == Path.new("aa")
		
			path = Path.new("bb")
			path = path.add(Path.new("aa"))
			path.should == Path.new("bb/aa")
		
			path = Path.new("/")
			path = path.add(Path.new("aa"))
			path.should == Path.new("/aa")
		end
	
		it "relative path" do
			path = Path.new("aa/bb/cc")
		
			path.size.should == 3
			
			str = ''
			path.each do |p|
				str << p.to_s
			end
			str.should == 'aabbcc'
		
			Path.new("bb/cc").should == "bb/cc"
			
			path.after('aa').should == 'bb/cc'
			path.after('bb').should == 'cc'
			path.after('cc').should == ''
			path.before('aa').should == ''
			path.before('bb').should == 'aa'
			path.before('cc').should == 'aa/bb'
		end						
    end
end