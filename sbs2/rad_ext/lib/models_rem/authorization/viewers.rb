class Models::Authorization::Viewers
  include Enumerable

  def initialize object, viewers
    @object, @viewers = object, viewers
  end

  delegate :each, :==, :inspect, :to_a, :to_s, to: :viewers

  def update_owner_name name
    viewers.delete_if{|role| role =~ /^user:.+/}
    viewers << "user:#{name}"
    viewers.sort!
  end

  def add role
    role = role.to_s
    should_be_valid_user_input_role role
    unless viewers.include? role
      viewers.replace Models::Authorization.with_all_higher_roles(viewers + [role])
    end
  end

  def delete role
    role = role.to_s
    should_be_valid_user_input_role role

    Models::Authorization.with_all_lower_roles([role]).each do |r|
      viewers.delete r
    end
    viewers << 'manager' unless viewers.include? 'manager'
    viewers.sort!

    object.collaborators.delete role
  end

  def minor
    roles = viewers.clone
    roles.delete 'manager'
    Models::Authorization.minor_roles roles
  end

  def validate_viewers
    viewers.must == viewers.uniq.sort

    viewers.must.include 'manager'
    viewers.must.include "user:#{object.owner_name}" if object.owner_name
  end

  protected
    attr_reader :object, :viewers
    delegate :should_be_valid_user_input_role, to: Models::Authorization
end