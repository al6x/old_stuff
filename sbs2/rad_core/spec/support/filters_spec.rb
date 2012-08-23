require 'spec_helper'

describe "Filters" do
  after{remove_constants :Tmp, :TmpBase}

  it 'basics' do
    class Tmp
      inherit Rad::Filters

      def action; 'result' end
      attr_reader :user

      protected
        def set_user; @user = 'some user' end
        before :set_user
    end

    o = Tmp.new
    o.run_callbacks(:action, :some_method){o.send :action}.should == 'result'
    o.user.should == 'some user'
  end

  it 'inheritance' do
    class TmpBase
      inherit Rad::Filters

      def action; 'result' end
      attr_reader :user

      protected
        def set_user; @user = 'some user' end
        before :set_user
    end

    class Tmp < TmpBase
      attr_reader :model

      protected
        def set_model; @model = 'some model' end
        before :set_model
    end

    o = Tmp.new
    o.run_callbacks(:action, :some_method){o.send :action}.should == 'result'
    o.user.should == 'some user'
    o.model.should == 'some model'
  end
end