unless Class.method_defined? :alias
  Class.class_eval do
    def alias name = nil
      if name
        raise "alias must be a String" unless name.is_a? String
        raise "alias must not be blank" if name.blank?
        @alias = name.to_s
      else
        @alias ||= self.name.split('::').last
      end
    end
  end
end