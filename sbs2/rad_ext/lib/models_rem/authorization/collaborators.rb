class Models::Authorization::Collaborators
  include Enumerable

  def initialize object, collaborators
    @object, @collaborators = object, collaborators
    @cache = {}
  end

  delegate :each, :==, :inspect, :to_a, :to_s, to: :collaborators

  def add role
    role = role.to_s
    should_be_valid_user_input_role role
    unless include? role
      collaborators << role
      object.viewers.add role
    end
    cache.clear
  end

  def delete role
    role = role.to_s
    should_be_valid_user_input_role role

    Models::Authorization.with_all_lower_roles([role]).each do |r|
      collaborators.delete r
    end

    cache.clear
  end

  def with_all_higher_roles
    @cache[:with_all_higher_roles] ||= begin
      list = Models::Authorization.with_all_higher_roles(collaborators)
      unless Models::Authorization.anonymous?(object.owner_name)
        list << "user:#{object.owner_name}"
      end
      list.sort!
      list
    end
  end

  def validate_collaborators
    collaborators.must_not.have_any{|role| role =~ /^user:.+/}
  end

  protected
    attr_reader :object, :collaborators, :cache
    delegate :should_be_valid_user_input_role, to: Models::Authorization
end