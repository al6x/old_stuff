class ControllerState < RubyExt::StateMashine
  class NestedActionState          
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
      return :View
    end
    
    def go_to
      @nesting_level = 0
      return :Initial
    end
  end
  
  initial_state :Initial
  transitions \
  [:Initial, :go_to, :Initial],
  [:Initial, :begin, :View],
  [:View, :begin, :Action],
  [:View, :end, :View],
  [:View, :go_to, :Initial],
  [:Action, :end, :View],
  [:Action, :cancel, :View],
  [:Action, :go_to, :Initial],
  [:Action, :begin, :NestedAction]
  custom_state :NestedAction, NestedActionState          
end