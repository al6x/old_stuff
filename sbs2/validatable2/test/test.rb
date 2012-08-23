require File.expand_path(File.dirname(__FILE__) + '/test_helper')

functional_tests do
  expect nil do
    klass = Class.new do
      include Validatable
      validates_presence_of :name, :level => 1, :message => "name message"
      validates_presence_of :address, :level => 2
      attr_accessor :name, :address
    end
    instance = klass.new
    instance.valid?
    instance.errors[:address]
  end
end