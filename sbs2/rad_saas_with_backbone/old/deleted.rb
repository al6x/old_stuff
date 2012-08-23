# if @token.save
#   UserMailer.email_verification(@token).deliver
#   flash.sticky_info = t :email_verification_code_sent, email: @token.email
#   redirect_to :follow_email_link
# else
#   render action: :enter_email_form
# end


persist_params

layout '/users/layout'

#
# Email and Password
#
def enter_email_form
  @token = Models::User::EmailVerificationToken.new
end
allow_get_for :enter_email_form


def follow_email_link
end
allow_get_for :follow_email_link


before :login_not_required, only: [
  :enter_email_form, :enter_email,
  :finish_email_registration_form, :finish_email_registration,

  :reset_password_form, :reset_password,
  :forgot_password_form, :forgot_password
]

def finish_email_registration_form
  @token = Models::User::EmailVerificationToken.by_token params.token
  raise_user_error t(:invalid_email_verification_token) unless @token

  @user = Models::User.new
end
allow_get_for :finish_email_registration_form


if @user.activate and @user.save
  @token.delete
  # flash.sticky_info = t :successfully_registered
  redirect_to login_path #(_return_to: nil)
else
  render action: :finish_email_registration_form
end



# TODO3 filter password logging
# filter_parameter_logging :password

persist_params

before :login_not_required, only: :login

layout '/users/layout'

allow_get_for :login, :logout, :status


def login
  if @user = Models::User.authenticate_by_password(params.name, params.password)
    set_current_user_with_updating_session @user
    flash.info = t :successfully_logged_in

    redirect_to return_to_path_for_login
  else
    @errors = t :invalid_login
    @name = params.name
  end
end

module RoutingHelper
  %w(login logout register).each do |path|
    define_method "#{path}_path" do |*args|
      options = parse_routing_arguments *args

      options = {
        # host: rad.users.host,
        # port: rad.users.port,
        url_root: rad.users.url_root,

        l: I18n.locale,
        _return_to: (workspace.params[:_return_to] || workspace.request.url)
      }.merge(options)

      build_url_path "/#{path}", options
    end
  end

  def user_path *args
    options = parse_routing_arguments *args

    options = {
      # host: rad.users.host,
      # port: rad.users.port,
      url_root: rad.users.url_root,

      l: I18n.locale
    }.merge(options)

    name = options.delete(:id)

    build_url_path "/profiles/#{name}/show", options
  end
end


def return_to_path_for_login
  return_to_path
end

def return_to_path_for_logout
  return_to_path
end


def set_current_user_with_updating_session user
  current_user = Models::User.current
  user.must_not == current_user

  # Clear
  clear_session!
  unless current_user.anonymous?
    Models::SecureToken.delete_all user_id: current_user._id.to_s
    response.delete_cookie 'auth_token'
  end

  # Set session and cookie token
  request.session['user_id'] = user._id.to_s
  unless user.anonymous?
    token = Models::SecureToken.new
    token[:user_id] = user._id.to_s
    token[:type] = 'cookie_auth'
    token.expires_at = 2.weeks.from_now
    token.save!

    response.set_cookie 'auth_token', value: token.token, expires: token.expires_at
  end

  Models::User.current = user
end


#
# Special
#
PRESERVE_SESSION_KEYS = %w{authenticity_token}
rad.after :http, bang: false do
  if rad.http.session
    session_id = rad.http.session.stringify_keys['key'] || raise("session key not defined!")
    PRESERVE_SESSION_KEYS << session_id unless PRESERVE_SESSION_KEYS.include? session_id
  end
end


def clear_session!
  session = request.session

  session['dumb_key'] # hack, need this to initialize session, othervise it's empty
  to_delete = session.keys.select{|key| !PRESERVE_SESSION_KEYS.include?(key.to_s)}
  to_delete.each{|key| session.delete key}
end


def login_from_cookie
  token = !request.cookies['auth_token'].blank? && Models::SecureToken.by_token(request.cookies['auth_token'])
  if token and !token[:user_id].blank?
    id = BSON::ObjectId.from_string token[:user_id]
    if user = Models::User.first(_id: id, state: 'active')
      request.session['user_id'] = user._id.to_s
      user
    end
  end
end

def login_from_session
  id = request.session['user_id']
  Models::User.by_id BSON::ObjectId.from_string(id) unless id.blank?
end

def login_as_anonymous
  request.session['user_id'] = Models::User.anonymous._id.to_s
  Models::User.anonymous
end


def reset_password_form
  @token = Models::User::ResetPasswordToken.by_token params.token
  raise_user_error t(:invalid_reset_password_token) unless @token
  @user = @token.user
end
allow_get_for :reset_password_form

def update_password_form
  @user = Models::User.current
  # render action: :update_password_form
end
allow_get_for :update_password_form


#
# Authorization stub
#

Controllers::Authenticated.class_eval do
  alias_method :prepare_current_user_without_test, :prepare_current_user
  def prepare_current_user_with_test; end
  alias_method :prepare_current_user, :prepare_current_user_with_test
end

rspec do
  def self.with_auth
    before :all do
      Controllers::Authenticated.send :alias_method, :prepare_current_user, :prepare_current_user_without_test
    end

    after :all do
      Controllers::Authenticated.send :alias_method, :prepare_current_user, :prepare_current_user_with_test
    end
  end
end






class HandyRoles < Array
  def include? role
    super role.to_s
  end
  alias_method :has?, :include?

  protected
    def method_missing m, *args, &block
      m = m.to_s
      super unless m[-1] == '?'

      self.include? m[0..-2]
    end
end


#
# Effective Permissions
#
def effective_permissions
  unless ep = _cache[:effective_permissions]
    ep = calculate_effective_roles_for roles
    _cache[:effective_permissions] = ep
  end
  ep
end

def effective_permissions_as_owner
  unless epo = _cache[:effective_permissions_as_owner]
    epo = calculate_effective_roles_for ['owner']
    _cache[:effective_permissions_as_owner] = epo
  end
  epo
end

protected
  def calculate_effective_roles_for roles
    effective_permissions = {}
    permissions = ::Models::Authorization::RealUserHelper.permissions
    permissions.each do |operation, allowed_roles|
      operation = operation.to_s
      effective_permissions[operation.to_s] = roles.any?{|role| allowed_roles.include? role}
    end
    effective_permissions
  end

  def validate_anonymous
    errors.add :base, "Anonymous can't have any roles!" if anonymous? and !roles.blank?
  end


def handy_roles
  unless roles = _cache[:roles]
    roles = if self.mm_roles.empty?
      ['user']
    else
      Models::Authorization.with_all_lower_roles(self.mm_roles)
    end
    if anonymous?
      roles << 'anonymous'
    else
      roles << 'registered'
    end
    roles << "user:#{name}" unless name.blank?
    if admin
      roles << 'admin'
      %w(manager member).each{|r| roles << r unless roles.include? r}
    end

    roles.must.be == roles.uniq

    roles = HandyRoles.new roles.sort
    _cache[:roles] = roles
  end
  roles
end
alias_method :roles, :handy_roles


# rad.extension :model_authorization, self do
#   define_method(:roles){@roles ||= []}
#   attr_writer :roles
#   # field :roles, type: Array, protected: true, default: []
#
#   alias_method :mm_roles,  :roles
#   alias_method :mm_roles=, :roles=
#
#   attr_accessor :admin
#   # field :admin, type: Boolean, protected: true, default: false
# end




# # Account.
#
# attr_accessor :account_id
# validates_presence_of :account_id
# def account
#   _cache[:account] ||= account_id && Models::Account.by_id(account_id)
# end
# def account= account
#   self.account_id = account._id
#   _cache[:account] = account
# end

# def validate_default_name
#   errors.add :base, t(:forbiden_to_change_default_space) if original and name != original.name and original.name == 'default'
# end
# protected :validate_default_name
# validate :validate_default_name
#
# def default?; name == 'default' end
# def self.default? name; name == 'default' end




# def slug; name end

class << self
  def default_space name
    if rad.production?
      space = (@default_space_cache ||= {})[name]
      unless space
        space = _default_space name
        # Smart cache, it caches only if space exist.
        @default_space_cache[name] = space if space
      end
      space
    else
      _default_space name
    end
  end

  protected
    def _default_space name
      default_account = Account.default_account
      default_account.spaces(name: name).first if default_account
    end
end






# def spaces selector = {}, options = {}
#   Models::Space.query selector.merge(account_id: _id), options
# end
# after_delete{|m| m.spaces.each &:delete!}
#
# def create_default_space
#   space = spaces.build
#   space.name = 'default'
#   space.save!
# end
# protected :create_default_space
# after_create :create_default_space


def get_space account
  space_name = params[:space]

  return nil unless space_name

  space = account.get_space space_name

  # select space on default account if space not exist
  # space = Models::Space.default_space space_name if !space

  # unless space
  #   msg = "no '#{space_name}' Space for '#{Models::Account.current.name}' Account"
  #   logger.debug msg
  #   raise msg
  # end
  # Models::Space.current = space
end