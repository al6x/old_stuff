require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module Spec
		module CascadeDelete
			describe "Events" do
				class CompositeEntity
					inherit Entity
					metadata do
						child :child
						child :children, :bag
					end
				end								
				
				it "Shouldn't allow to assign non-Entities to Children" do
					lambda{
						@r.transaction{
							@r['e'].child = "string"
						}.commit
					}.should raise_error(/Child should be Entity or Nil/)
					
					lambda{
						@r.transaction{
							@r['e'].children << "string"
						}.commit
					}.should raise_error(/Child should be Entity or Nil/)
				end
				
				it "Shouldn't allow to assign self as Child" do
					lambda{
						@r.transaction{
							entity = @r['e']
							entity.child = entity
						}.commit
					}.should raise_error(/Forbiden to add self as Child/)
				end
				
				it "Shouldn't allow to assign the same Child twice (for the same Entity)" do
					lambda{
						@r.transaction{
							entity = @r['e']
							child = CompositeEntity.new 'child'
							entity.child = child
							entity.children << child
						}.commit
					}.should raise_error(/Forbiden to add the same Child twice/)
				end
				
				it "Delete should delete Entity from it's Parent Childrens" do
					@r.transaction{
						p = CompositeEntity.new 'parent'
						
						c1 = CompositeEntity.new 'child1'
						c2 = CompositeEntity.new 'child2'
						
						p.child = c1
						p.children << c2
					}.commit
					
					@r.transaction{
						@r['parent/child1'].delete
						@r['parent/child2'].delete
					}.commit					
					
					@r['parent'].child.should be_nil
					@r['parent'].children.should be_empty					
				end
				
				it "Should also delete all Children for_deleted Entity" do
					@r.transaction{
						p = CompositeEntity.new 'parent'
						
						c1 = CompositeEntity.new 'child1'
						c2 = CompositeEntity.new 'child2'
						
						p.child = c1
						p.children << c2
					}.commit
					
					@r.transaction{
						@r['parent'].delete
					}.commit
					
					@r.should_not include('parent')
					@r.should_not include('child1')
					@r.should_not include('child2')
					@r.should_not include('parent/child1')
					@r.should_not include('parent/child1')
				end
				
				it "Deleting Child from Children should also delete Child.parent but not delete Child themself" do
					@r.transaction{
						p = CompositeEntity.new 'parent'
						
						c1 = CompositeEntity.new 'child1'
						c2 = CompositeEntity.new 'child2'
						
						p.child = c1
						p.children << c2
					}.commit
					
					tr = @r.transaction{
						p = @r['parent']
						p.child = nil
						p.children.clear
					}
					@r['parent'].child.should_not be_nil
					@r['parent/child1'].parent.should_not be_nil
					@r['parent/child2'].parent.should_not be_nil
					
					tr.commit
					@r['parent'].child.should be_nil
					@r['parent'].children.should be_empty
					@r['child1'].parent.should be_nil
					@r['child2'].parent.should be_nil
					@r.should include('child1')
					@r.should include('child2')
					@r.should_not include('parent/child1')
					@r.should_not include('parent/child2')
				end
				
				before :each do
					ObjectModel::CONFIG[:directory] = "#{File.dirname __FILE__}/data"
					
					Repository.delete :test
					@r = Repository.new :test
					@r.transaction{CompositeEntity.new 'e'}.commit
				end
				
				after :each do
					@r.close
					Repository.delete :test
				end
			end
		end
	end
end
