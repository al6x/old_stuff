module TheNamespace
  class ClassB
    def self.problem_method
      raise_without_self "Some problem"
    end

    def self.exclude_multiple_classes
      raise_without_self "Some problem", AnotherClass
    end
  end
end