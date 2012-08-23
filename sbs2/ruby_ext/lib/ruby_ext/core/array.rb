Array.class_eval do
  alias_method :add, :push

  def sfilter *filters
    filters = filters.first if filters.size == 1 and filters.first.is_a?(Array)
    filters.collect!{|o| o.is_a?(Regexp) ? o : /#{Regexp.escape o}/}
    self.select do |line|
      !filters.any?{|re| line =~ re}
    end
  end

  def self.wrap value
    Array(value)
  end

  alias_method :blank?, :empty?

  alias_method :filter, :select

  def extract_options
    last.is_a?(Hash) ? last : {}
  end

  def extract_options!
    last.is_a?(Hash) ? pop : {}
  end
end