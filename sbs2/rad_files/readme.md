# 2
kit/models.rb: require 'kit/paperclip'

# 3 

user.rb

user.rb

  space_field :files_size, type: Integer, default: 0
  validate do |u|
    u.space_keys_containers.size.must == 0 if u.anonymous?
  end
  
# 5

bag/item.rb

  # 
  # Icon
  # 
  include Paperclip

  has_attached_file :icon, styles: {icon: "50x50#", thumb: "150x150#"}, default_style: :icon
  validates_file :icon
  trace_file :icon
  def icon_url; icon.url end