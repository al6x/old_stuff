require 'MicroContainer/require'
require 'spec'

module MicroContainer
  describe "MicroContainer" do		
    class InstanceScope
      extend Managed
      scope :instance
    end
    
    it "Instance Scope" do
      i = Scope[InstanceScope]
      i.equal?(Scope[InstanceScope]).should be_false
    end
    
    class ApplicationScope
      extend Managed
      scope :application
    end
    
    class A
      extend Managed
      scope :instance
      inject :application => ApplicationScope
    end						
    
    class ValueScope
      extend Injectable
      inject :value2 => :value2
    end
    
    it "Should allow explicit registration" do
      Scope.register :identifier, :session do
        1
      end
      
      MicroContainer::ScopeManager.activate_thread :session_id do			
        Scope[:identifier].should == 1
      end
    end
    
    it "Injection and explicit access from Scope should works the same way" do
      vs = ValueScope.new
      Scope.register :value2, :thread
      MicroContainer::ScopeManager.activate_thread :key do                                
        Scope[:value2].should be_nil
        
        Scope[:value2] = 1
        vs.value2.should == 1
        
        vs.value2 = 2
        Scope[:value2].should == 2
      end
    end
    
    it "Application Scope" do
      a = Scope[A]
      a.application.is_a?(ApplicationScope).should be_true
      object_id = a.application.object_id
      
      Scope.register :value, :application
      
      Scope[:value].should be_nil
      Scope[:value] = 1
      
      Scope.register :value2, :application
      vs = ValueScope.new
      vs.value2.should be_nil
      vs.value2 = 2
      
      # Double check	
      a = Scope[A]		
      a.application.object_id.should == object_id
      
      Scope[:value].should == 1
      
      vs.value2.should == 2
    end
    
    class ThreadScope
      extend Managed
      scope :thread
    end		
    
    it "Thread Scope" do
      rs, vs = nil, ValueScope.new
      MicroContainer::ScopeManager.activate_thread :key do
        rs = Scope[ThreadScope]
        rs.equal?(Scope[ThreadScope]).should  be_true
        
        Scope.register :value, :thread                
        Scope[:value].should be_nil
        Scope[:value] = 1
        Scope[:value].should == 1
        
        Scope.register :value2, :thread
        vs.value2.should be_nil
        vs.value2 = 2
        vs.value2.should == 2
      end
      
      MicroContainer::ScopeManager.activate_thread :key do	
        rs.equal?(Scope[ThreadScope]).should  be_false
        
        Scope[:value].should be_nil
        
        vs.value2.should be_nil
      end
    end
    
    #		it "Should raise error if Thread not started" do
    #			lambda{Scope[ThreadScope}.should raise_error
    #        end
    
    class SessionScope
      extend Managed
      scope :session			
    end
    
    it "Session" do			
      s, vs = nil, ValueScope.new
      MicroContainer::ScopeManager.activate_thread :key do
        s = Scope[SessionScope]
        s.should_not be_nil	
        
        Scope.register :value, :session
        Scope[:value].should be_nil
        Scope[:value] = 1
        
        Scope.register :value2, :session
        vs.value2.should be_nil
        vs.value2 = 2
      end
      
      MicroContainer::ScopeManager.activate_thread :key do		
        s.equal?(Scope[SessionScope]).should be_true			
        
        Scope[:value].should == 1
        
        vs.value2.should == 2
      end
    end
    
    class CycleB; end
    
    class CycleA
      extend Managed
      scope :application
      inject :b => CycleB
    end
    
    class CycleB
      extend Managed
      scope :application
      inject :a => CycleA
    end
    
    it "Cycle reference" do
      a = Scope[CycleA]
      b = Scope[CycleB]
      a.b.equal?(b).should be_true
      b.a.equal?(a).should be_true
    end				
    
    #	class ConversationScope
    #		include Managed
    #		scope :conversation
    #	end
    #		
    #	it "Should automatically create Conversation Scope" do
    #		c = nil
    #		MicroContainer::ScopeManager.activate_thread :key do
    #			c = Scope[ConversationScope]
    #			c.should_not be_nil
    #			c.equal?(Scope[ConversationScope]).should be_true
    #		end
    #				
    #		MicroContainer::ScopeManager.activate_thread :key do		
    #			c.equal?(Scope[ConversationScope]).should be_false
    #		end
    #	end
    #		
    #	class ConversationScopeController
    #		include Managed
    #		scope :application
    #						
    #		def start; end
    #		scope_begin :start
    #			
    #		def stop; end					
    #		scope_end :stop
    #	end
    #		
    #	it "Explicitly controlled Conversation Scope" do
    #		c = nil
    #		MicroContainer::ScopeManager.activate_thread :key do
    #			controller = Scope[ConversationScopeController]
    #			controller.start				
    #			c = Scope[ConversationScope]
    #			c.should_not be_nil				
    #		end
    #
    #		MicroContainer::ScopeManager.activate_thread :key do
    #			c.equal?(Scope[ConversationScope]).should be_true			
    #			controller = Scope[ConversationScopeController]
    #			controller.stop
    #		end
    #			
    #		MicroContainer::ScopeManager.activate_thread :key do	
    #			c.equal?(Scope[ConversationScope]).should be_false
    #		end
    #	end			
    #		
    #	it "Nested Conversations" do
    #		MicroContainer::ScopeManager.activate_thread :key do
    #			controller = Scope[ConversationScopeController]
    #			controller.start				
    #			c = Scope[ConversationScope]
    #			c.should_not be_nil				
    #			
    #			controller.start
    #			nested = Scope[ConversationScope]
    #			nested.should_not be_nil				
    #			nested.equal?(c).should be_false
    #			controller.stop
    #			
    #			c2 = Scope[ConversationScope]	
    #			c2.equal?(c).should be_true
    #			
    #			controller.stop
    #		end
    #	end						
    
    it "Outjection ApplicationScope Scope" do			
      Scope[ApplicationScope] = "new value"
      Scope[ApplicationScope].should == "new value"
      
      Scope.register :value2, :application
      vs = ValueScope.new
      vs.value2 = "v2"
      vs.value2.should == "v2"
    end
    
    it "Outjection Thread Scope" do
      MicroContainer::ScopeManager.activate_thread :key do
        Scope[ThreadScope] = "new value"
        Scope[ThreadScope].should == "new value"	
      end
    end
    
    it "Outjection Session Scope" do
      MicroContainer::ScopeManager.activate_thread :key do
        Scope[SessionScope] = "new value"
        Scope[SessionScope].should == "new value"
      end
    end
    
    
    
    #	it "Outjection Conversation Scope" do
    #		MicroContainer::ScopeManager.activate_thread :key do
    #			Scope[ConversationScope] = "new value"
    #			Scope[ConversationScope].should == "new value"
    #		end
    #	end
  end
end


















