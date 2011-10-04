require 'MicroContainer/require'
require 'spec'

module MicroContainer
  Thread.abort_on_exception = true  
  
  describe "Session management" do		
    
    it "Shouldn't remove session if there is active threads " do
      ScopeManager.activate_thread :sid do
      end
      t = Thread.new do
        ScopeManager.process_async_observers_for_session :sid
      end
      sleep 0.1
      t.should be_alive
      ScopeManager.delete_sessions_older_than 0.01
      t.should_not be_alive
    end
    
    it "Should collects only expired sessions" do
      ScopeManager.activate_thread :expired do		
      end
      sleep 0.1
      ScopeManager.activate_thread :sid do
      end
      sleep 0.01
      
      sessions = Scope.instance_variable_get('@sessions')
      sessions.size.should == 2
      ScopeManager.delete_sessions_older_than 0.1
      sessions.size.should == 1
    end
    
    it "Should call Before & After" do
      sleep 0.1
      ScopeManager.delete_sessions_older_than 0.01
      
      mock = mock("Before & After")                  
      
      Scope.before(:session){mock.before}      
      Scope.after(:session){mock.after}      
        
      mock.should_receive(:before)        
      ScopeManager.activate_thread(:session_id){}            
      ScopeManager.activate_thread(:session_id){}
      sleep 0.1                  
      mock.should_receive(:after)

      ScopeManager.delete_sessions_older_than 0.01      
    end
  end
end
