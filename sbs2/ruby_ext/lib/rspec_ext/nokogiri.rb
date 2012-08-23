# Helpers to express expectation about html nodes.
require 'nokogiri'

class RSpec::FuzzyHash < Hash
  def == o
    return true if super

    if o.respond_to? :each
      o.each do |k, v|
        return false if (self[k.to_sym] || self[k.to_s]) != v
      end
      return true
    end

    false
  end
end

::Nokogiri::XML::Node.class_eval do
  def to_fuzzy_hash
    h = RSpec::FuzzyHash.new
    attributes.each{|n, v| h[n] = v.value}
    h[:content] = content
    h
  end
end