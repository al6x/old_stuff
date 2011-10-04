require 'sm_commons/factories'

# Factory.define :resource do |r|
#   r.space{Space.current}
#   r.rating 0
#   r.resource_type "Post"
#   r.sequence(:resource_id){|i| i}
#   # r.association :account, :factory => :account
# end
# 
# 
# Factory.define :vote do |v|
#   v.space{Space.current}
#   v.value 1
#   v.state 'active'
#   v.association :resource, :factory => :resource
#   v.association :user, :factory => :user
# end
# 
# Factory.define :comment do |v|
#   v.space{Space.current}
#   v.sequence(:text){|i| "Comment #{i}"}
#   v.state 'active'
#   v.association :resource, :factory => :resource
#   v.association :user, :factory => :user
# end