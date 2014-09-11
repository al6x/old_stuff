require 'utils/state_mashine'

module Utils
	describe "State Mashine" do
		class Meta < StateMashine			
			initial :Creation
			transitions [:Creation, :create, :View],
				[:View, :edit, :Edit],
				[:Edit, :save, :View],
				[:Edit, :cancel, :View],
				[:View, :delete, :Deleted]
        end
		
		class BareMeta < StateMashine			
			transitions [:Created, :delete, :Deleted]				
        end
		
		class MetadataTest < StateMashine
			transitions [:s1, :fun, :s2], [:s3, :fun, :s4]
        end
		
		before :each do
			@state = Meta.new
		end
		
		it "Initial State" do
			@state.should == :Creation
        end
		
		it "Transfer function" do
			@state.create
			@state.should == :View
        end
		
		it "==" do
			state2 = Meta.new
			@state.should == state2
			@state.should == :Creation
        end
		
		it "before & after" do
			@state.on_entry :View, :entry
			@state.on_exit :View, :_exit
			
			mock = mock("Events")
			@state.object = mock
			
			mock.should_receive(:entry).twice
			@state.create
			mock.should_receive(:_exit)
			@state.edit
			
			@state.cancel
			@state.on_entry :View, nil
			@state.on_exit :View, nil
					
			@state.edit			
        end
		
		it "Invalid method" do
			lambda{@state.invalid_m}.should raise_error(RuntimeError, /Invalid State Transfer Method/)
        end
		
		it "Invalid state" do
			lambda{@state.delete}.should raise_error{/Can't call Transfer Method/}
        end
		
		it "Bare State" do
			s = BareMeta.new
			s.state.should be_nil
			s.state = :Created
			s.state = :Deleted
        end
    end
end



















