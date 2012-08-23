require "spec_helper"

describe "Synchronize" do
  it "synchronize_method" do
    class SAccount
      attr_reader :from, :to

      def initialize
        super
        @from, @to = 0, 0
      end

      def transfer
        @from -= 1
        @to += 1
      end
      synchronize_method :transfer
    end

    a, threads = SAccount.new, []
    100.times do
      t = Thread.new do
        100.times{a.transfer}
      end
      threads << t
    end
    threads.each{|t| t.join}

    a.from.should == -10_000
    a.to.should == 10_000
  end

  it "synchronize_all_methods" do
    class SAccount2
      attr_reader :from, :to

      def initialize
        super
        @from, @to = 0, 0
      end

      def transfer
        @from -= 1
        @to += 1
      end
      synchronize_all_methods
    end

    a, threads = SAccount2.new, []
    100.times do
      t = Thread.new do
        100.times{a.transfer}
      end
      threads << t
    end
    threads.each{|t| t.join}

    a.from.should == -10_000
    a.to.should == 10_000
  end

  it "singleton" do
    class SAccount3
      class << self
        def a; end
        synchronize_method :a
      end
    end
    SAccount3.a
  end

  it "shouldn't allow to synchronize twice" do
    class SAccount4
      def a; end
    end
    SAccount4.synchronize_method :a
    -> {SAccount4.synchronize_method :a}.should raise_error(/twice/)
  end
end