require "spec_helper"

describe 'Kernel' do
  after_all{remove_constants :TheNamespace, :AnotherClass}

  it "raise_without_self" do
    require "#{spec_dir}/TheNamespace/ClassA"
    require "#{spec_dir}/the_namespace/class_b"
    require "#{spec_dir}/another_class"

    begin
      TheNamespace::ClassA.problem_method
    rescue StandardError => e
      e.message.should =~ /Some problem/
      stack = e.backtrace
      stack.any?{|line| line =~ /ClassA/}.should be_false
      stack.any?{|line| line =~ /kernel_spec/}.should be_true
    end

    begin
      TheNamespace::ClassB.problem_method
    rescue StandardError => e
      e.message.should =~ /Some problem/
      stack = e.backtrace
      stack.any?{|line| line =~ /class_b/}.should be_false
      stack.any?{|line| line =~ /kernel_spec/}.should be_true
    end

    begin
      AnotherClass.exclude_multiple_classes
    rescue StandardError => e
      e.message.should =~ /Some problem/
      stack = e.backtrace
      stack.any?{|line| line =~ /class_b/}.should be_false
      stack.any?{|line| line =~ /another_class/}.should be_false
      stack.any?{|line| line =~ /kernel_spec/}.should be_true
    end
  end
end