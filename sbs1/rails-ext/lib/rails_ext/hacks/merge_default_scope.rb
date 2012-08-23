# Merges default_scopes and accepts blocks
if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do
    class << self
      def default_scoping
        hash_poser = HashPoser.new do 
          hashes = merged_default_scopes.collect do |scope| 
            scope = scope.is_a?(Proc) ? scope.call : scope
            scope[:create] ||= {}
            scope
          end
        
          merged = hashes.inject({}, :deep_merge)
          { :find => merged, :create => (merged[:conditions] || {})}
        end
        [hash_poser]
      end
    end
  end
end