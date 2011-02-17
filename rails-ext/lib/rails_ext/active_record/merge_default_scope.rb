# Merges default_scopes and accepts blocks
if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do
    class_inheritable_accessor :merged_default_scopes
    self.merged_default_scopes = []
  
    class << self
      def default_scope options = nil, &block
        self.merged_default_scopes << (options || block).should_not!(:be_nil)
      end
        
      # open with_exclusive_scope
      public :with_exclusive_scope
    end
  end
end