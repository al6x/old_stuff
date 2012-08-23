module Mongoid::AttributeCache
  extend ActiveSupport::Concern
  
  def cache
    @cache ||= {}
  end

  def clear_cache
    @cache = {}
  end

  def reload
    @cache.clear if @cache
    super
  end
end