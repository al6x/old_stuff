require 'spec_helper'

describe "Authorizations" do
  after{remove_constants :AController}
  before do
    @user = Object.new
    rad.user = @user
  end
  after{rad.delete :user}

  it "should protect controller and require authorization" do
    class AController
      inherit Rad::Controller, Controllers::Authorization
    end
    c = AController.new

    -> {c.send :access_denied!}.should raise_error(UserError)

    @user.should_receive(:can?).with(:update).and_return false
    -> {c.send :require_permission, :update}.should raise_error(UserError)

    @user.should_receive(:can?).with(:update, 'An Object').and_return false
    -> {c.send :require_permission, :update, 'An Object'}.should raise_error(UserError)

    @user.should_receive(:can?).with(:update).and_return true
    c.send :require_permission, :update
  end

  it "should provide declaraive helpers" do
    class AController
      inherit Rad::Controller, Controllers::Authorization

      require_permission :update, only: :update

      require_permission :delete, only: :delete do
        'An Object'
      end

      def update; :ok end
      def delete; :ok end
    end
    c = AController.new

    c.should_receive(:require_permission).with(:update, nil).and_raise(UserError)
    -> {c.update}.should raise_error(UserError)

    c.should_receive(:require_permission).with(:delete, 'An Object').and_raise(UserError)
    -> {c.delete}.should raise_error(UserError)

    c.should_receive(:require_permission)
    c.delete.should == :ok
  end
end