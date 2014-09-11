
require 'ObjectModel/require'
require 'spec'
require "#{File.dirname(__FILE__)}/timer"

module ObjectModel
	module Spec
		module ExtendedSpec
			describe "Repository Extended" do	
				class SimpleEntity
					inherit Entity
					
					metadata do 
						attribute :name, :string
						attribute :value		
						reference :reference
					end
				end	   
				
				it "Asquisition should search in Parent's methods untill found not-nil value (from error)" do
					@r.transaction{
						p = UpNotNil.new 'p'
						p.value = "Value"
						UpNotNil.new 'c'
					}.commit					
					@r['c'].up(:value).should == nil
					@r.transaction{
						@r['p'].child = @r['c']
					}.commit
					@r['p/c'].up(:value).should == "Value"										
				end
				
				it "Asquisition shouldn't raise 'Not found' if Parent hasn't method returning nil" do
					@r.transaction{
						p = UpParent.new 'p' # Hasn't :value method
						c = UpNotNil.new 'c'
						p.child = c
					}.commit
					@r['p/c'].up(:value).should == nil
				end								
				
				it "Custom Initialization" do
					@r.transaction{
						CustomInitialization.new 'ci'
					}.commit
					e = @r['ci']
					[e.string, e.number, e.boolean, e.object, e.data, e.date].should == 
					["ci", 1, true, 45, StreamID.new("sid"), DateTime.new(2009, 1, 1)]
				end				
				
				it "Entities can be used as Hash keys (from error)" do
					@r.transaction{SimpleEntity.new 'e'}.commit
					@r['e'].should == @r['e']
					{@r['e'] => 1}.should == {@r['e'] => 1}
					[@r['e']].to_set.should == [@r['e']].to_set
				end
				
				it "Should correct restore om_id, entity_id and om_repository after loading" do			
					@r.transaction{SimpleEntity.new 'e', 'om_id'}.commit
					@r['e'].om_id.should == "om_id"
					@r['e'].entity_id.should == "e"
					@r['e'].om_version.should_not be_nil
					@r['e'].om_version.should_not == 0
					@r['e'].om_repository.should == @r
				end
				
				it "Commit inside Transaction block" do
					@r.transaction{|t|
						SimpleEntity.new 'e'
						t.commit
					}
					@r.should include('e')
				end
				
				it "Should correct save cycle references" do			
					@r.transaction{
						a = SimpleEntity.new 'a'
						b = SimpleEntity.new 'b'
						b.reference = a
						a.reference = b						
					}.commit		
					
					@r['a'].reference.should == @r['b']
					@r['b'].reference.should == @r['a']
				end	
				
				it "Should save special characters" do
					@r.transaction{
						e = SimpleEntity.new 'e' 
						e.name = "<test>\"'&"
					}.commit
					
					@r['e'].name.should == "<test>\"'&"
				end		
				
				it "Shouldn't allow '/' symbol in entity_id" do
					lambda{
						@r.transaction{
							SimpleEntity.new 'ivalid/symbol'
						}.commit
					}.should raise_error(/'\/'/)
				end
				
				it %{
					Tricky spec. Inside Transaction scope Entity Lookup 
					should use 'Transaction.resolve' not 'Repository.by_id'					
				} do
					@r.transaction do
						e1 = SimpleEntity.new
						e2 = SimpleEntity.new.set :name => "e2"
						e1.reference = e2
						e1.reference.name.should == "e2" # <= Entity Lookup in this line shouldn't cause Error
					end
				end
				
				it "Transaction should have default name" do
					tr = @r.transaction{}
					tr.name.should == "default"
				end
				
				it "Should also works with entities accessed outside Transaction scope" do
					# We can use it without isolate, but we can't then guarantee integrity
					# becouse if we use NoCache Cache it creates new entity each time.
					# So if we first access Entity and remember it without :isolate another 
					# process can change this Entity.
					@r.transaction{
						SimpleEntity.new 'e'
					}.commit
					@r.isolate do 						
						e = @r['e']
						@r.transaction{
							e.name = "new name"
						}.commit
						@r['e'].name.should == "new name"
						# e.name.should == "new name" # but this will be not always true!
					end					
				end
				
				it "Shouldn't allow create Entity with empty entity_id" do
					@r.transaction{
						lambda{SimpleEntity.new ""}.should raise_error(/shouldn't be Emtpy/)
					}
				end
				
				it "Should be able to save some simple metadata" do
					s = @r.storage
					s.get("key").should be_nil
					s.put("key", "value")
					s.get("key").should == "value"
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
end