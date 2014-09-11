require 'RubyExt/require'
require 'spec'

module RubyExt
  module Spec
    describe "State Mashine" do
      class Meta < StateMashine
        initial_state :Creation
        transitions [:Creation, :create, :View],
        [:View, :edit, :Edit],
        [:Edit, :save, :View],
        [:Edit, :cancel, :View],
        [:View, :delete, :Deleted]
      end
      
      class BareMeta < StateMashine
        initial_state :Created
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
      
      it "Exceptions in event processing should cause rollback in state change" do
        @state.on_event :Creation, :create do
          raise
        end
        lambda{@state.event :create}.should raise_error
        @state.state.should == :Creation
      end
      
      it "Should properly process events inside another event (from error)" do
        @state.on_event :Creation, :create do
          @state.event :edit
        end
        @state.event :create
        @state.state.should == :Edit
      end
      
      it "Transfer function" do
        @state.event :create
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
        @state.event :create
        mock.should_receive(:_exit)
        @state.event :edit
        
        @state.event :cancel
        @state.on_entry :View, nil
        @state.on_exit :View, nil
        
        @state.event :edit
      end
      
      it "on_event" do
        mock = mock("Events")
        mock.should_receive :create
        @state.on_event :Creation, :create do
          mock.create
        end
        @state.event :create
      end
      
      it "should also use block as action" do
        mock = mock("Events")
        @state.on_entry :View do
          mock.entry
        end                
        
        mock.should_receive(:entry)
        @state.event :create
      end
      
      it "Invalid method" do
        lambda{@state.event :invalid}.should raise_error(/There is no :invalid Event in :Creation State/)
      end
      
      it "Invalid state" do
        lambda{@state.event :delete}.should raise_error(/There is no :delete Event in :Creation State!/)
      end
      
      it "Bare State" do
        s = BareMeta.new        
        s.state = :Deleted
      end
      
      # (Waiting) - begin -> (Action) - begin -> (NestedAction) - begin n-times -> (NestedAction)
      #           <- end   -          <- end   -                < end n-times    -
      #           <- cancel                    - 
      it "Custom Recursive State" do
        class NestedAction          
          def initialize
            @nesting_level = 0
          end
          
          def begin
              @nesting_level += 1
              :NestedAction
            end
            
            def end
            if @nesting_level == 0
              return :Action
            else
              @nesting_level -= 1  
              return :NestedAction
            end
          end
          
          def cancel
            @nesting_level = 0
            return :Waiting
          end
          
          # Not required, can be omited
          def state state
            case state
              when :Action
              @nesting_level = 0
              return :Action
            else nil
            end
          end
        end
        
        class CustomState < StateMashine
          initial_state :Waiting
          transitions [:Waiting, :begin, :Action],
          [:Action, :end, :Waiting],
          [:Action, :begin, :NestedAction]
          custom_state :NestedAction, NestedAction
        end
        
        sm = CustomState.new
        sm.event :begin
        sm.state.should == :Action
        sm.event :begin
        sm.state.should == :NestedAction
        
        # Nested :begin/:end
        sm.event :begin
        sm.state.should == :NestedAction
        sm.event :begin
        sm.state.should == :NestedAction
        
        sm.event :end
        sm.state.should == :NestedAction
        sm.event :end
        sm.state.should == :NestedAction
        lambda{sm.event :invalid}.should raise_error(/There is no :invalid Event in :NestedAction State/)
        
        sm.event :end
        sm.state.should == :Action
        
        # Nested :cancel
        sm.event :begin
        sm.state.should == :NestedAction
        sm.event :begin
        sm.state.should == :NestedAction
        sm.event :cancel
        sm.state.should == :Waiting
        
        # Correct working after :cancel
        sm.event :begin
        sm.state.should == :Action
        sm.event :begin
        sm.state.should == :NestedAction
        sm.event :end
        sm.state.should == :Action
        
        # Should also works with "state= ..."
        sm.event :begin
        sm.state.should == :NestedAction
        sm.state = :Action
        sm.state.should == :Action
      end
    end
  end
end