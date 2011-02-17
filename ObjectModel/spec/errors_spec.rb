require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module ErrorsSpec
		describe "ErrorsSpec" do	
			before :each do
				CONFIG[:directory] = "#{File.dirname __FILE__}/data"
				Repository.delete :test
				@r = Repository.new :test
			end
			
			after :each do
				@r.close
				Repository.delete :test
			end
			
			class SimpleEntity
				inherit Entity
				
				metadata do
					attribute :label, :string
					attribute :value, :object
					child :child
				end
			end
			
			it "Shouldn't raise UniqueEntityID when saving Entity" do
				@r.transaction{SimpleEntity.new("e")}.commit
				@r.transaction{@r["e"].name = "e"}.commit # <= Error was here
			end
			
			it "Instead of UniqueOMID error raises some strange error" do
				@r.transaction{SimpleEntity.new("e", "e")}.commit
				lambda{
					@r.transaction{SimpleEntity.new("e", "e")}.commit
				}.should raise_error(/Not Unique :entity_id/)
			end
			
			it "Should fill name before :after_commit (from error)" do
				@r.transaction{AfterCommitError.new("name")}.commit
				#					e = @r["name"]
				#					p e
			end								
			
			it "Changing name doesn't affects cache" do
				restore = ObjectModel::CONFIG[:cache]
				ObjectModel::CONFIG[:cache] = "ObjectModel::Tools::InMemoryCache"
				Repository.delete :test2
				r = Repository.new :test2
				begin
					
					r.transaction{SimpleEntity.new("e")}.commit
					r.transaction{r["e"].name = "e2"}.commit
					r["e2"].name.should == "e2"
					
				ensure
					ObjectModel::CONFIG[:cache] = restore
					r.close
					Repository.delete :test2
				end
			end
		end
	end
end