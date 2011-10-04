require 'ObjectModel/require'
require 'spec'

module ObjectModel
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
					attribute :label, :string
					child :child
					child :children, :bag
				end
			end
			
			it "Access by Path" do
				@r.transaction{
					p = SimpleEntity.new('p').set :label => 'Parent'
					c1 = SimpleEntity.new('c1').set :label => 'Child1'
					c2 = SimpleEntity.new('c2').set :label => 'Child2'
					p.child = c1
					p.children << c2
				}.commit
				
				@r.should include('p/c1')
				@r.should include('p/c2')
				@r['p/c1'].label.should == "Child1"
				@r['p/c2'].label.should == "Child2"
			end
			
			it "Change name" do
				@r.transaction{
					p = SimpleEntity.new 'e', 'id1'
					p.name = 'e2'
				}.commit
				@r.should_not include('e')
				@r.should include('e2')
				
				tr = @r.transaction{
					e = @r['e2']
					e.name = 'e3'
					e.name.should == 'e3'
				}
				@r.should include('e2')
				
				tr.commit
				@r.should_not include('e2')
				@r.should include('e3')
			end
			
			it "Check duplicate name beneath Children" do					
				@r.transaction{
					p = SimpleEntity.new 'p'
					lambda{
						SimpleEntity.new 'p'
					}.should raise_error(/Not unique/)
				}												
			end
			
			it "Check duplicate name when moving from Root Space to Children" do					
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
			
			it "Check duplicate name between Existing Entity and New One" do					
				@r.transaction{
					SimpleEntity.new 'p'
				}.commit
				@r.transaction{
					lambda{
						SimpleEntity.new 'p'
					}.should raise_error(/Not unique/)
				}
			end								
			
			it "Check duplicate name when moving Entity to Root space" do
				@r.transaction{
					p = SimpleEntity.new 'p'
					p.child = c = SimpleEntity.new
					p.child.name = 'p'
					lambda{
						p.child = nil
						p c.parent
					}.should raise_error(/Not unique/)
				}.commit										
			end
			
			it "Check duplicate name when moving Entity to Another Entity" do
				@r.transaction{
					p1 = SimpleEntity.new 'p1', 'id1'
					p2 = SimpleEntity.new 'p2'
					c1 = SimpleEntity.new 'c1'
					c2 = SimpleEntity.new 'c2'
					p1.child = c1
					p2.child = c2
					
					c2.name = 'c1'
					lambda{
						p1.children << c2							
					}.should raise_error(/Not unique/)
				}.commit					
			end
			
			it "Entity methods: [], include_child?" do
				@r.transaction{
					p = SimpleEntity.new 'p'
					c = SimpleEntity.new('c').set :label => "child"
					p.child = c
				}.commit			
				@r['p'].should include('c')
				@r['p']['c'].label.should == "child"
				lambda{@r['p']['invalid']}.should raise_error(NotFoundError)
			end				
			
			it "path" do
				@r.transaction{
					p = SimpleEntity.new 'p'
					c = SimpleEntity.new('c').set :label => "child"
					p.child = c
				}.commit			
				@r['p'].path.should == 'p'
				@r['p/c'].path.should == 'p/c'
			end
		end
	end
end
