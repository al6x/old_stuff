require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module Spec
		module BasicSpec
			describe "BasicSpec" do												
				
				it "Base Types, Initialization and Save & Load" do
					@r.transaction{
						BaseTypes.new 'bt'
					}.commit
					e = @r['bt']
					[e.string, e.number, e.boolean, e.object, e.data, e.date].should == 
					["", 0, false, nil, nil, nil]
				end												
				
				it "Should Asquise Parent's methods" do
					@r.transaction{
						UpParent.new 'parent'
						UpChild.new 'child'
					}.commit
					@r['child'].up(:up_child, "Some param").should == :up_child
					lambda{@r['child'].up(:up_parent, "Some param")}.should raise_error(NoMethodError)
					
					@r.transaction{@r['parent'].child = @r['child']}.commit
					@r['parent/child'].up(:up_parent, "Some param").should == :up_parent										
				end								
				
				it "DMeta inheritance" do
					Descendant.meta.attributes.keys.sort.should == [:base_class_method, :descendant_method]
				end								
				
				it "each" do
					@r.transaction{
						p = EachTest.new 'p', 'p_id'
						c1 = EachTest.new 'c1', 'c1_id'
						c2 = EachTest.new 'c2', 'c2_id'
						
						p.child = c1
						p.children << c2
						
						p.reference = c1
						p.references << c2
						p.references << c2
						
						c3 = EachTest.new 'c3', 'c3_id'
						c2.child = c3
						c2.reference = c3
					}.commit
					
					list = []
					@r['p'].each(:attribute){|value| list << value}
					list.size.should == 2
					list.to_set.should == ["a1", "a2"].to_set
					
					list = []
					@r['p'].each(:child){|child| list << child.entity_id}
					list.size.should == 2
					list.to_set.should == ["c1", "c2"].to_set
					
					list = []
					@r['p'].each(:reference){|value| list << value.entity_id
					}
					list.size.should == 3
					list.to_set.should == ["c1", "c2", "c2"].to_set					
				end		
				
				class SimpleEntity
					inherit Entity
					
					metadata do
						attribute :name, :string
						attribute :value, :object
					end
				end
				
				it "Write & Read" do		
					@r.should_not include('e')
					tr = @r.transaction{SimpleEntity.new('e').name = "name"}
					@r.should_not include('e')
					tr.commit		
					@r.should include('e')
					@r['e'].name.should == "name"
					@r['e'].entity_id.should == 'e'
				end
				
				it "Should return used transaction in commit" do			
					tr = @r.transaction{SimpleEntity.new}.commit
					tr.copies.size.should == 1
				end												
				
				it "Long transaction" do
					e = nil
					tr = @r.transaction{e = SimpleEntity.new 'e'}
					@r.should_not include('e')
					@r.transaction(tr){e.name = "name"}
					tr.commit
					@r['e'].name.should == "name"
				end
				
				it "Set entity_id by hand" do
					@r.transaction{
						SimpleEntity.new('e', 'om_id').set :name => 'name'
						}.commit											
					@r.should include('e')
					@r.by_id('om_id').name.should == 'name'
				end										
				
				it "Rollback" do
					@r.transaction{SimpleEntity.new 'e'}
					@r.should_not include('e')
				end
				
				it "Should correct save ValueObject" do
					@r.transaction{SimpleEntity.new('e').set :value => ["value"]}.commit										
					@r['e'].value.should == ["value"]
				end
				
				it "Should freeze ValueObject" do
					@r.transaction{SimpleEntity.new('e').set :value => ["value"]}.commit										
					lambda{@r['e'].value << 1}.should raise_error(/frozen/)
				end
				
				it "Each Entity in Repository" do
					@r.transaction{
						SimpleEntity.new 'e'
						SimpleEntity.new 'e2'
					}.commit	
					
					list = []					
					@r.each{|e| list << e.entity_id}
					list.size.should == 2
					list.to_set.should == ["e", "e2"].to_set
				end				
				
				it "Not allowed to change objects outside transaction" do
					@r.transaction{SimpleEntity.new 'e'}.commit	
					lambda{SimpleEntity.new}.should raise_error(NoTransactionError)
					lambda{@r['e'].value = :value}.should raise_error(NoTransactionError)
				end								
				
				it "Should not allow to start two the same simultaneously" do
					lambda {
						Repository.new 'test'
					}.should raise_error(/the same/)
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
			end
		end
	end
end