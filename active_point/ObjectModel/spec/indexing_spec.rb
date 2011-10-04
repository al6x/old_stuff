require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module IdexingSpec
		describe "Indexing" do					
			class SimpleEntity
				inherit Entity
				
				metadata do
					attribute :value, :number
				end
			end
			
			it "Should create Index on the fly" do
				@r.add_index(HashIndex.new(:square){|e| e.value ** 2})
				
				@r.index(:square)[4].value.should == 2
				
				@r.transaction{
					SimpleEntity.new('e').set :value => 4
				}.commit					
				@r.index(:square)[16].value.should == 4
				
				@r.delete_index(:square)					
				lambda{@r.index(:square)}.should raise_error(/No Index/)
			end
			
			it "Should be able to rebuild index" do
				@r.add_index(HashIndex.new(:square){|e| e.value ** 2})					
				@r.index(:square)[4].value.should == 2
				
				@r.clear_indexes
				@r.build_indexes
				@r.index(:square)[4].value.should == 2
			end
			
			before :each do
				CONFIG[:directory] = "#{File.dirname __FILE__}/data"
				Repository.delete :test
				@r = Repository.new :test
				
				@r.transaction{
					SimpleEntity.new('a').set :value => 1
					SimpleEntity.new('b').set :value => 2
					SimpleEntity.new('c').set :value => 3
				}.commit
			end
			
			after :each do
				@r.close
				Repository.delete :test
			end
		end
	end
end