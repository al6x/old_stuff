require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module EventsSpec						
		describe "Events" do				
			class MockListener				
				attr_reader :events, :arguments
				def initialize
					@events, @arguments = [], []
				end
				
				def method_missing m, *p, &b						
					@events << m
					@arguments << p
				end
				
				def respond_to? symbol
					true
				end
				
				def clear
					@events.clear
				end
			end
			
			before :each do
				ObjectModel::CONFIG[:directory] = "#{File.dirname __FILE__}/data"
				
				Repository.delete :test									
				@r = Repository.new :test
				@l = MockListener.new
				@r.entity_listeners << @l
			end
			
			after :each do
				@r.close
				Repository.delete :test
			end
			
			class EventEntity
				inherit Entity
				metadata do
					attribute :attribute, :string
					reference :reference
					child :child
				end
			end
			
			it "attribute_update" do 
				@r.transaction{EventEntity.new 'e'}.commit
				@l.clear
				tr = @r.transaction{@r['e'].attribute = "string"}.commit
				@l.events.should == [
				:before_attribute_update, :after_attribute_update, 
				:before_commit, :after_commit
				]
				tr.copies.values[0].updated?.should be_true
			end
			
			it "new_reference, delete_reference and new_referrer, delete_referrer" do
				@r.transaction{EventEntity.new 'e'}.commit
				@l.clear
				@r.transaction{@r['e'].reference = @r['e']}.commit					
				@l.events.should == [
				:before_new_reference, 
				:before_new_referrer, :after_new_referrer, 
				:after_new_reference, 
				:before_commit, :after_commit
				]
				
				@l.clear
				tr = @r.transaction{@r['e'].reference = nil}.commit
				@l.events.should == [
				:before_delete_reference, 
				:before_delete_referrer, :after_delete_referrer, 
				:after_delete_reference, 
				:before_commit, :after_commit
				]
				tr.copies.values[0].updated?.should be_true
			end
			
			it "new_child, delete_child and new_parent, delete_parent" do
				@r.transaction{EventEntity.new 'e'; EventEntity.new 'child'}.commit
				@l.clear
				@r.transaction{@r['e'].child = @r['child']}.commit
				@l.events.should == [
				:before_new_child, 
				:before_new_parent, :after_new_parent, 
				:after_new_child, 
				:before_commit, :after_commit
				]
				
				@l.clear
				tr = @r.transaction{@r['e'].child = nil}.commit
				@l.events.should == [:before_delete_child, 
				:before_delete_parent, :after_delete_parent, 
				:after_delete_child, 
				:before_commit, :after_commit
				]
				
				updated = 0
				tr.copies.size.should == 2
				tr.copies.values.each do |copy|
					updated += 1 if copy.updated?
				end
				updated.should == 2
			end				
			
			it "new, delete" do
				@l.clear
				tr = @r.transaction{EventEntity.new 'e'}.commit
				@l.events.should == [:before_new, :before_name_update, :after_name_update, :after_new, :before_commit, :after_commit]
				tr.copies.values[0].new?.should be_true
				
				@l.clear
				@r.transaction{@r['e'].delete}.commit
				@l.events.should == [:before_delete, :after_delete, :before_commit, :after_commit]										
			end
			
			it "move" do
				@r.transaction{
					p1 = EventEntity.new 'p1'
					EventEntity.new 'p2'
					p1.child = EventEntity.new 'child'				
				}.commit
				
				@l.clear
				tr = @r.transaction{@r['p2'].child = @r['p1/child']}.commit
				@l.events.should == [
				:before_new_child, 
				:before_delete_child, 
				:before_delete_parent, :after_delete_parent, 
				:after_delete_child, 
				:before_move, 
				:before_new_parent, :after_new_parent, 
				:after_move, 
				:after_new_child, 
				:before_commit, :after_commit]
				
				updated, moved = 0, 0
				tr.copies.size.should == 3
				tr.copies.values.each do |copy|
					updated += 1 if copy.updated?
					moved += 1 if copy.moved?
				end
				[updated, moved].should == [3, 1]
			end				
			
			class OnEntity
				inherit Entity
				metadata do
					attribute :before, :string
					attribute :after, :string
					
					before :new do
						self.before += "before new"
					end
					
					after :new do
						self.after += "after new"
					end
				end
			end
			
			it "Changes made to Entity during Events should be Commited." do
				@r.transaction{OnEntity.new 'e'}.commit
				@r['e'].before.should == "before new"
				@r['e'].after.should == "after new"
			end
		end
	end
end