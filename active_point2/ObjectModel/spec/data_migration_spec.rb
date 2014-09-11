require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module DataMigrationSpec
		describe "Data Migration" do	
			it "when loading outdated attribute instead of :default check_for :initialize" do					
				class InitEntity
					inherit Entity
					
					metadata do 
					end
				end	   
				
				@r.transaction{InitEntity.new "ie"}.commit
				
				class InitEntity
					inherit Entity
					
					metadata do 
						attribute :value, :object, :initialize => "custom value"
					end
				end	   
				
				@r.transaction{
					@r["ie"].value.should == "custom value"
				}.commit
			end
			
			before :all do
				@restore = ObjectModel::CONFIG[:cache]
				ObjectModel::CONFIG[:cache] = "ObjectModel::Tools::NoCache"
			end
			
			after :all do
				ObjectModel::CONFIG[:cache] = @restore
			end
			
			before :each do
				CONFIG[:directory] = "#{File.dirname __FILE__}/data"
				Repository.delete :test
				@r = Repository.new :test
			end
			
			after :each do
				@r.close
				Repository.delete :test
			end
		end
	end
end