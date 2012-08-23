require 'rad/tasks'
require 'mongo/model/integration/rad/tasks'

namespace :saas do
  desc "Creates :anonymous and :admin (name: admin, password: admin) users"
  task initialize: :environment do
    rad.saas

    # Anonymous.
    Models::User.delete_all({name: 'anonymous'}, validate: false)
    Models::User.new.set!(
      name: 'anonymous',
      email: "anonymous@localhost",
      password: "anonymous_password",
      password_confirmation: "anonymous_password",
      state: 'active'
    ).save! validate: false

    # Admin.
    Models::User.delete_all({name: 'admin'}, validate: false)
    admin = Models::User.new
    admin.set!(
      name:  'admin',
      email: "admin@localhost",
      state: 'active',
      global_admin: true,

      password: 'admin',
      password_confirmation: 'admin'
    )
    admin.roles.add :admin
    admin.save! validate: false

    # Account and Space for localhost.
    Models::Account.by_name('default').try :delete
    account = Models::Account.new name: 'default'
    account.domains.unshift 'localhost'
    account.save!
  end

  desc "Fills database with sample data"
  task fill_with_sample_data: :environment do
    require 'rspec_ext/factory'
    require 'saas/spec/_factories'

    # Generating users.
    rad.activate :cycle do
      rad.account = Models::Account.by_name! 'default'
      rad.space = rad.account.get_space 'default'

      100.times do |i|
        user = if i % 10 == 0
          factory.build :admin
        elsif i % 5 == 0
          factory.build :manager

        elsif i % 2 == 0
          factory.build :member
        else
          factory.build :user
        end

        Models::User.delete_all name: user.name
        user.save!
      end
    end

    # Generating Accounts.
    100.times do |i|
      account = factory.build :account

      rand(5).times do |i|
        space = factory.build :space, account: account
        account.spaces << space
      end

      account.enabled = false if i % 10 == 0

      Models::Account.delete_all name: account.name
      account.save!
    end
  end
end