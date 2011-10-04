require 'ObjectModel/require'
require 'spec'

module ObjectModel
	module ValidationSpec
		describe "ValidationSpec" do					
			
			it "TypeCheck" do
				@r.transaction{
					e = BaseTypes.new 'e'
					lambda{e.string = 1}.should raise_error(ValidationError)
					lambda{e.number = ""}.should raise_error(ValidationError)
					lambda{e.boolean = 1}.should raise_error(ValidationError)
					lambda{e.object = lambda{}}.should raise_error(ValidationError)
					lambda{e.data = 1}.should raise_error(ValidationError)
					lambda{e.date = 1}.should raise_error(ValidationError)
				}
			end
			
			class Parent
				inherit Entity
				
				metadata do
					attribute :label, :string
					
					validate do							
						raise "Invalid Parent" if label == "parent invalid"
					end
				end
			end
			
			class Child < Parent
				inherit Entity
				
				metadata do												
					validate do
						raise "Invalid Child" if label == "child invalid"
					end
				end
			end
			
			it "Should inherit Validation from Parents" do
				@r.transaction{Child.new.set :label => "name"}.commit
				lambda{
					@r.transaction{Child.new.set :label => "parent invalid"}.commit
				}.should raise_error(/Invalid Parent/)
				lambda{
					@r.transaction{Child.new.set :label => "child invalid"}.commit
				}.should raise_error(/Invalid Child/)
			end
			
			it "Should allow explicitly Validate Entity" do
				@r.transaction{Child.new.set :label => "name"}.commit
				@r.transaction{
					c = Child.new.set :label => "parent invalid"
					lambda{c.validate}.should raise_error(/Invalid Parent/)
				}										
			end
			
			class AttributeValidation
				inherit Entity
				
				metadata do
					attribute :label, :string, :validate => lambda{|v| raise "error" if v == "invalid"}
				end
			end
			
			it "Attribute Validation" do
				@r.transaction{
					e = AttributeValidation.new
					lambda{e.label = "invalid"}.should raise_error(ValidationError)
				}
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