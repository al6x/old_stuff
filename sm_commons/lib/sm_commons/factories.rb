# 
# User
# 
Factory.define :blank_user, :class => User do |u|
  u.sequence(:name){|i| "user#{i}"}
end

Factory.define :new_user, :class => User do |u|
  u.sequence(:name){|i| "user#{i}"}
  u.sequence(:email){|i| "user#{i}@email.com"}
  u.sequence(:password){|i| "user#{i}"}
  u.password_confirmation{|_self| _self.password}
end

Factory.define :user, :parent => :new_user do |u|
  u.state 'active'
end

Factory.define :open_id_user, :class => User do |u|
  u.sequence(:name){|i| "user#{i}"}
  u.sequence(:open_ids){|i| ["open_id_#{i}"]}
  u.state 'active'
end 

Factory.define :anonymous, :class => User, :parent => :new_user do |u|
  u.name 'anonymous'
  u.email "anonymous@mail.com"
  u.password "anonymous_password"
  u.password_confirmation{|_self| _self.password}
end

Factory.define :admin, :class => User, :parent => :new_user do |u|
  u.admin_of_accounts{[Account.current.id]}
  # u.roles_containers{[RolesContainer.new(:space_id => Space.current.id, :roles => %w{member manager})]}
  u.space_roles{%w{member manager}}
end

Factory.define :member, :class => User, :parent => :new_user do |u|
  # u.roles_containers{[RolesContainer.new(:space_id => Space.current.id, :roles => %w{member})]}
  u.space_roles{%w{member}}
end

Factory.define :manager, :class => User, :parent => :member do |u|
  # u.roles_containers{[RolesContainer.new(:space_id => Space.current.id, :roles => %w{member manager})]}
  u.space_roles{%w{member manager}}
end

Factory.define :global_admin, :parent => :user, :parent => :new_user do |u|
  u.global_admin true
end


# 
# Account and Space
# 
Factory.define :account do |a|
  a.name "test-account"
end

Factory.define :space do |s|
  s.name "default"
  s.account{|a| a.association(:account)}
end