describe "Set Cookie Token" do
  it "should set remember me token" do
    user = factory.create :user
    pcall Controllers::Sessions, :login, name: user.name, password: user.password do |c|
      c.call

      Models::SecureToken.count.should == 1
      token = Models::SecureToken.first
      token[:user_id].should == user._id.to_s

      response.cookies.should =~ /auth_token=#{token.token}/
    end
  end
end

describe "Restore user from Cookie Token" do
  it "any action in domain controller" do
    user = factory.create :user

    token = Models::SecureToken.new
    token[:user_id] = user._id.to_s
    token.expires_at = 2.weeks.from_now
    token.save!

    pcall SomeDomain, :all do |c|
      request.cookies['auth_token'] = token.token
      c.call
    end

    Models::User.current.name.should == user.name
  end
end

describe "Miscellaneous" do
  it "should show status" do
    call Controllers::Sessions, :status
    response.should be_ok
  end
end