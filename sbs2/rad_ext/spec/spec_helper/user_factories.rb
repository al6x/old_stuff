factory.define :user, class: 'Models::UserStub' do |u|
  u.name = "an_user_#{factory.next}"
  u.roles = ["user:#{u.name}", 'user', 'registered']
end

factory.define :anonymous, parent: :user do |u|
  u.name = 'anonymous'
  u.roles = ['user', 'anonymous'].sort
end

factory.define :member, parent: :user do |u|
  u.name = "a_member_##{factory.next}"
  u.roles = ["user:#{u.name}", 'member', 'user', 'registered'].sort
end

factory.define :manager, parent: :user do |u|
  u.name = "a_manager_##{factory.next}"
  u.roles = ["user:#{u.name}", 'manager', 'member', 'user', 'registered'].sort
end

factory.define :admin, parent: :user do |u|
  u.name = "an_admin_##{factory.next}"
  u.roles = ["user:#{u.name}", 'admin', 'manager', 'member', 'user', 'registered'].sort
end