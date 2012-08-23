module TheNamespace
  class ClassA
    def self.problem_method
      raise_without_self "Some problem"
    end
  end
end