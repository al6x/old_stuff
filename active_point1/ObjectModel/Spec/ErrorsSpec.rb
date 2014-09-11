require 'ObjectModel/require'
require 'spec'
require "#{File.dirname(__FILE__)}/timer"

module ObjectModel
	module Spec
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
						attribute :name, :string
						attribute :value, :object
					end
				end
				
				it "Shouldn't raise UniqueEntityID when saving Entity" do
					@r.transaction{SimpleEntity.new("e")}.commit
					@r.transaction{@r["e"].entity_id = "e"}.commit # <= Error was here
				end
				
				it "Instead of UniqueOMID error raises some strange error" do
					@r.transaction{SimpleEntity.new("e", "e")}.commit
					lambda{
					@r.transaction{SimpleEntity.new("e", "e")}.commit
					}.should raise_error(/Not Unique :om_id/)
				end
			end
		end
	end
end
