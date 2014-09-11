require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module ComplexEventsSpec						
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
			
			class BeforeRollbackEntity
				inherit Entity
				metadata do
					before :new do
						raise "abort"
					end
				end
			end								
			
			class AfterRollbackEntity
				inherit Entity
				metadata do
					after :new do
						raise "abort"
					end
				end
			end								
			
			it "Should Rollback Transaction if Exception is thrown during Before & After Event" do
				lambda{
					@r.transaction{BeforeRollbackEntity.new 'e'}.commit
				}.should raise_error(/abort/)
				@r.should_not include('e')
				
				lambda{
					@r.transaction{AfterRollbackEntity.new 'e'}.commit
				}.should raise_error(/abort/)
				@r.should_not include('e')
			end
			
			class AfterCommitEntity
				inherit Entity
				metadata do						
					after :commit do
						raise "abort"
					end
				end
			end
			
			it "Shouldn't Rollback Transaction if Exception is thrown during after_commit" do
				lambda{
					@r.transaction{AfterCommitEntity.new 'e'}.commit
				}.should raise_error(/abort/)
				@r.should include('e')
			end
			
			class User
				inherit Entity
				metadata do
					child :folder
					after :new do |e|
						e.folder = UserFolder.new "#{e.name} folder"
					end
				end
			end
			
			class UserFolder
				inherit Entity			
				metadata{}
			end
			
			it "Changing another Entity during Event" do
				@r.transaction{User.new 'u'}.commit
				@r['u'].folder.name.should == "u folder"
			end
			
			class BaseEntity
				inherit Entity
				metadata do
					after :new do
						BaseEntity.events << "base"
					end
				end
				
				def self.events 
					@events ||= []
				end
			end
			
			class DescendantEntity < BaseEntity					
				metadata do
					after :new do
						BaseEntity.events << "descendant"
					end
				end
			end
			
			it "Events call sequence, first SuperClass Events should be called" do
				@r.transaction{DescendantEntity.new 'de'}.commit
				BaseEntity.events.should == ["base", "descendant"]
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
		end
	end
end