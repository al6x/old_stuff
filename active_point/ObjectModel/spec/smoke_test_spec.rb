require 'ObjectModel/require'
require 'spec'

module ObjectModel
	describe "SmokeTest" do	
		class ESample
			inherit Entity
			metadata do
				name :esample
				child :bag, :bag						
			end
		end
		
		it "Metadata, entity_id and name Initialization" do							
			@r.transaction do
				e = ESample.new
				e.name.should_not be_nil			
				e.entity_id.should_not be_nil
				e.should respond_to(:bag)
			end
			
			ESample.meta.children[:bag].type.should == Types::BagType
			ESample.meta.name.should == :esample					
		end
		
		class SimpleEntity
			inherit Entity			
			metadata do
				attribute :label, :string
				#				attribute :value_object, :object
			end
		end
		
		it "Create & Delete Entity" do
			@r.transaction{
				SimpleEntity.new 'eid'
			}.commit
			@r.should include('eid')
			@r.transaction{
				@r['eid'].delete
			}.commit
			
			@r.should_not include('eid')
		end
		
		class VOTest
			inherit Entity
			metadata do
				attribute :value_object, :object
			end
		end
		
		class CustomValueObject
			attr_accessor :value
		end
		
		it "ValueObjects" do
			vo = CustomValueObject.new
			vo.value = "value"
			
			@r.transaction{
				e = VOTest.new 'eid'
				e.value_object = vo
			}.commit
			@r['eid'].value_object.value.should == "value"
			
			@r.transaction{
				@r['eid'].value_object = nil
			}.commit			
			@r['eid'].value_object.should be_nil
		end
		
		before :each do
			CONFIG[:directory] = "#{File.dirname __FILE__}/data"
			
			Repository.delete :test
			@r = Repository.new(:test)
		end
		
		after :each do
			@r.close
			Repository.delete :test
		end	
	end
end
