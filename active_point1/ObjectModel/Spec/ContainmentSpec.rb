require 'ObjectModel/require'
require 'spec'
require "#{File.dirname(__FILE__)}/timer"

module ObjectModel
	module Spec
		module ContainmentSpec
			describe "Containment" do	
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
						attribute :name, :string
						child :child
						child :children, :bag
					end
				end
				
				it "Access by Path" do
					@r.transaction{
						p = SimpleEntity.new('p').set :name => 'Parent'
						c1 = SimpleEntity.new('c1').set :name => 'Child1'
						c2 = SimpleEntity.new('c2').set :name => 'Child2'
						p.child = c1
						p.children << c2
					}.commit
					
					@r.should include('p/c1')
					@r.should include('p/c2')
					@r['p/c1'].name.should == "Child1"
					@r['p/c2'].name.should == "Child2"
				end
				
				it "Change entity_id" do
					@r.transaction{
						p = SimpleEntity.new 'e', 'id1'
						p.entity_id = 'e2'
					}.commit
					@r.should_not include('e')
					@r.should include('e2')
					
					tr = @r.transaction{
						e = @r['e2']
						e.entity_id = 'e3'
						e.entity_id.should == 'e3'
					}
					@r.should include('e2')
					
					tr.commit
					@r.should_not include('e2')
					@r.should include('e3')
				end
				
				it "Check duplicate entity_id beneath Children" do					
					@r.transaction{
						p = SimpleEntity.new 'p'
						lambda{
							SimpleEntity.new 'p'
						}.should raise_error(/Not unique/)
					}												
				end
				
				it "Check duplicate entity_id when moving from Root Space to Children" do					
					@r.transaction{
						p = SimpleEntity.new 'p'
						c = SimpleEntity.new 'c'
						p.child = c
						
						c2 = SimpleEntity.new 'c'
						lambda{
							p.children << c2
						}.should raise_error(/Not unique/)
					}										
				end
				
				it "Check duplicate entity_id between Existing Entity and New One" do					
					@r.transaction{
						SimpleEntity.new 'p'
					}.commit
					@r.transaction{
						lambda{
							SimpleEntity.new 'p'
						}.should raise_error(/Not unique/)
					}
				end								
				
				it "Check duplicate entity_id when moving Entity to Root space" do
					@r.transaction{
						p = SimpleEntity.new 'p'
						p.child = c = SimpleEntity.new
						p.child.entity_id = 'p'
						lambda{
							p.child = nil
							p c.parent
						}.should raise_error(/Not unique/)
					}.commit										
				end
				
				it "Check duplicate entity_id when moving Entity to Another Entity" do
					@r.transaction{
						p1 = SimpleEntity.new 'p1', 'id1'
						p2 = SimpleEntity.new 'p2'
						c1 = SimpleEntity.new 'c1'
						c2 = SimpleEntity.new 'c2'
						p1.child = c1
						p2.child = c2
						
						c2.entity_id = 'c1'
						lambda{
							p1.children << c2							
						}.should raise_error(/Not unique/)
					}.commit					
				end
				
				it "Entity methods: [], include_child?" do
					@r.transaction{
						p = SimpleEntity.new 'p'
						c = SimpleEntity.new('c').set :name => "child"
						p.child = c
					}.commit			
					@r['p'].should include('c')
					@r['p']['c'].name.should == "child"
					lambda{@r['p']['invalid']}.should raise_error(NotFoundError)
				end				
				
				it "entity_path" do
					@r.transaction{
						p = SimpleEntity.new 'p'
						c = SimpleEntity.new('c').set :name => "child"
						p.child = c
					}.commit			
					@r['p'].entity_path.should == 'p'
					@r['p/c'].entity_path.should == 'p/c'
				end
			end
		end
	end
end
