require 'spec_helper'

describe "Authorization, Roles" do
  with_models

  roles = Models::Authorization

  it "with_all_higher_roles" do
    roles.with_all_higher_roles(%w(member user:user1)).should ==
      %w(admin manager member user:user1)
    roles.with_all_higher_roles(%w(manager user:auser user)).should ==
      %w(admin manager member user user:auser)
  end

  it "with_all_lower_roles" do
    roles.with_all_lower_roles(%w(member user:user1)).should ==
      %w(member user user:user1)
  end

  it "major_roles" do
    roles.major_roles(%w(member user user:user1 registered)).should ==
      %w(member user:user1)
  end

  it "minor_roles" do
    roles.minor_roles(%w(member user user:user1 registered)).should ==
      %w(user user:user1)
  end
end