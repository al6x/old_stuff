# Users.

factory.define :blank_user, class: 'Models::User' do |u|
  u.name = "user_#{factory.next}"
end

factory.define :new_user, class: 'Models::User' do |u|
  n = factory.next :user
  u.name = "user_#{n}"
  u.email = "user#{n}@email.com"
  u.password = "password #{n}"
  u.password_confirmation = u.password
end

factory.define :user, parent: :new_user do |u|
  u.state = 'active'
end

factory.define :anonymous, parent: :new_user do |u|
  u.name = 'anonymous'
  u.email = "anonymous@mail.com"
  u.password = "anonymous_password"
  u.password_confirmation = u.password
  u._cache.clear
end

factory.define :admin, parent: :new_user do |u|
  u.roles.add 'admin'
end

factory.define :member, parent: :new_user do |u|
  u.roles.add 'member'
end

factory.define :manager, parent: :member do |u|
  u.roles.add 'manager'
end

factory.define :global_admin, parent: :user do |u|
  u.global_admin = true
  u._cache.clear
end

# Account and Space.

factory.define :account, class: 'Models::Account' do |a|
  n = factory.next :account
  a.name = "account-#{n}"
end

factory.define :space, class: 'Models::Space' do |s|
  n = factory.next :space
  s.name = "space-#{n}"

  s.account = factory :account
  s.account.spaces << s
end