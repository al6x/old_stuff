require 'kit/support'

# Configs
class Rad::Kit
  attr_accessor :default_item, :tags_count
  attr_required :tags_count
  def items; @items ||= [] end
end

rad.router.class.class_eval do
  attr_accessor :default_url
  attr_required :default_url
end



# Kit
#
# TODO3 move :text_utils to standalone gem
%w(
  support
  controller
  i18n
  kit_text_utils

  misc/prepare_model
  misc/user_error
).each{|f| require "kit/#{f}"}