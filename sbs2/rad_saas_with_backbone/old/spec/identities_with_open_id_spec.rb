require 'saas_extensions/users/spec_helper'

OpenIdAuthentication.class_eval do
  def authenticate_with_open_id identifier = nil, options = {}, &block
    openid_identifier = params[:openid_identifier]
    raise 'invalid usage' if openid_identifier.nil?
    block.call(
      {successful: true}.to_openobject,
      openid_identifier,
      "some not used parameters"
    )
  end
end

describe "Identities" do
  with_controllers
  set_controller Controllers::Identities

  describe "Signup using OpenId" do
    before do
      @token = Models::SecureToken.new
      @token[:open_id] = "some_id"
      @token.save!

      @return_to = "http://some.com/some".freeze
      @escaped_return_to = "http%3A%2F%2Fsome.com%2Fsome".freeze

      login_as Models::User.anonymous
    end

    def form_action_should_include_return_to
      Nokogiri::XML(response.body).css("form").first[:action].should include(@escaped_return_to)
    end

    it "finish_open_id_registration" do
      pcall :finish_open_id_registration, user: {name: 'user1'}.stringify_keys, token: @token.token, _return_to: @return_to

      cas_token = Models::SecureToken.by_type('cas')
      cas_token.should_not be_nil
      response.should redirect_to(@return_to + "?cas_token=#{cas_token.token}")

      user = Models::User.find_by_name 'user1'
      user.should be_active
      user.should_not be_nil
      Models::User.current.should == user
    end
  end
end