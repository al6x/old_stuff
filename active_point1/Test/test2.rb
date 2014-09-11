{
	:top => [:a, :b]
}

exit


#require 'benchmark'
#require 'set'
#
#a = Multiset.new
#10_000.times{|i| a[i] = true}
#
#b = Multiset.new
#100.times{|i| b[i] = true}
#
#Benchmark.bmbm do |bm|
#  bm.report("1000") do
#  	10000.times{a.include? 2056}
#  end
#  bm.report("10") do
#    10000.times{b.include? 56}
#  end
#end

require "RubyExt/require"
class ObjectModel
	inherit Log
	class A
		inherit Log
	end
end


#ObjectModel.log.error "fuck"
#ObjectModel.new.log.error "fuck"


require 'sequel'

DB = Sequel.connect('sqlite://Test/blog.db')
DB.logger = ObjectModel.log

begin 
	DB.drop_table :items
	DB.drop_table :entities
rescue
end


DB.create_table :items do # Create a new table
	primary_key :id
	column :name, :text
	column :price, :int
end

DB.create_table :entities do
	column :entity_id, :text
	column :class, :text
	
	column :og_version, :text				
	column :parent_id, :text
	
	column :extra, :text
	primary_key :entity_id
end

entities = DB[:entities]
p entities[:entity_id => "eid"]

items = DB[:items] # Create a dataset
items

# Populate the table
items << {:name => 'abc', :price => rand * 100}
begin
	DB.transaction do
		items << {:name => 'def', :price => rand * 100}
		items << {:name => 'ghi', :price => rand * 100}
		raise "adf"
	end
rescue
end

# Print out the number of records
puts "Item count: #{items.count}"

puts items[:name => "abc"]

# Print out the records in descending order by price
items.reverse_order(:price).print

# Print out the average price
puts "The average price is: #{items.avg(:price)}"