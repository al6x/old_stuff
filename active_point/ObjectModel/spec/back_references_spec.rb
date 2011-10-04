require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module BackReferences
		describe "BackReferences" do			
			class SimpleEntity
				inherit Entity
				metadata do
					reference :reference
					reference :references, :bag
				end
			end	            
			
			it "Adding & Deleting" do
				@r.transaction{				
					e1 = SimpleEntity.new 'e1'
					e2 = SimpleEntity.new 'e2'
					
					e1.reference = e2
					e1.references << e2
				}.commit
				
				@r['e1'].back_references.size.should == 0
				@r['e2'].back_references.size.should == 2
				
				@r.transaction{
					@r['e1'].reference = nil
					@r['e1'].references.clear
				}.commit					
				
				@r['e1'].back_references.size.should == 0
				@r['e2'].back_references.size.should == 0
			end
			
			class EntityWithVO
				inherit Entity
				metadata do
					attribute :object, :object
				end
			end
			
			it "Shouldn't count ValueObjects" do
				@r.transaction{
					e = EntityWithVO.new 'e'
					e.object = []
				}.commit
				@r['e'].back_references.size.should == 0
			end
			
			
			it "Create & Delete cycle Reference" do
				@r.transaction{				
					e1 = SimpleEntity.new 'e1'
					e2 = SimpleEntity.new 'e2'
					e1.reference = e2
					e2.reference = e1
				}.commit
				@r['e1'].back_references.size.should == 1
				@r['e2'].back_references.size.should == 1
				
				@r.transaction{
					@r['e1'].reference = nil
					@r['e2'].reference = nil
				}.commit
				@r['e1'].back_references.size.should == 0
				@r['e2'].back_references.size.should == 0
			end
			
			it "Reference to themself" do
				@r.transaction{				
					e = SimpleEntity.new 'e'
					e.reference = e
				}.commit
				@r['e'].back_references.size.should == 1
				
				@r.transaction{
					@r['e'].reference = nil
				}.commit
				@r['e'].back_references.size.should == 0
			end
			
			it "Should not update BackReferences until_Commit" do
				@r.transaction{
					SimpleEntity.new 'e1'
					SimpleEntity.new 'e2'
				}.commit
				
				tr = @r.transaction{														
					@r['e1'].reference = @r['e2']					
					@r['e2'].back_references.size.should == 1
				}				
				@r['e2'].back_references.size.should == 0
				
				tr.commit									
				@r['e2'].back_references.size.should == 1
			end
			
			it "Deleting Entities should cause deleting all references to thouse Entities" do
				@r.transaction{				
					e1 = SimpleEntity.new 'e1', 'e1'
					e2 = SimpleEntity.new 'e2', 'e2'
					e2.reference = e2
					e1.reference = e2
					e1.references << e2
				}.commit
				@r['e1'].reference.should_not be_nil
				@r['e2'].back_references.size.should == 3
				
				@r.transaction{
					@r['e2'].delete
					@r['e2'].reference.should be_nil	
				}.commit								
				@r['e1'].reference.should be_nil
				@r['e1'].references.size.should == 0
				@r['e1'].back_references.size.should == 0												
			end
			
			class CascadeDeleteEntity
				inherit Entity
				metadata do
					reference :reference
					child :child
				end
			end
			
			it "Cascade BackReferences delete" do
				@r.transaction{				
					p = CascadeDeleteEntity.new 'parent'
					c = SimpleEntity.new 'child'
					p.child = c
					
					referrer = SimpleEntity.new 'referrer'
					referrer.reference = c
					referrer.references << c
					referrer.references << p
				}.commit
				@r['referrer'].reference.should_not be_nil
				@r['referrer'].references.size.should == 2
				
				@r.transaction{
					@r['parent'].delete
				}.commit
				@r['referrer'].reference.should be_nil
				@r['referrer'].references.size.should == 0
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
