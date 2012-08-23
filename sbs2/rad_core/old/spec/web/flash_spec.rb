require 'spec_helper'
require 'html/spec_helper'

describe "Flash" do
  with_prepare_params

  isolate :conveyors, :router, before: :all

  before :all do
    rad.mode = :development, true
    rad.web

    class MockFlashContext < TestTemplateContext
      include Rad::Html::FlashHelper, Rad::ControllerRoutingHelper

      def build_url *args;
      end
    end

    class FlashTestRenderCaller < Rad::Conveyors::Processor
      def call
        context = MockFlashContext.new
        block = workspace.check_flash.request
        catch :halt do
          block.call context if block
        end
        workspace.request_done = true

        next_processor.call
      end
    end

    class FlashTestHelper < Rad::Conveyors::Processor
      def call
        block = workspace.check_flash.before_request
        block.call workspace if block
        workspace.before_request_done = true

        next_processor.call

        block = workspace.check_flash.after_request
        block.call workspace if block
        workspace.after_request_done = true
      end
    end


    rad.conveyors.web do |web|
      web.use Rad::Http::Processors::PrepareParams
      web.use FlashTestHelper
      web.use Rad::Html::Processors::PrepareFlash
      web.use FlashTestRenderCaller
    end
  end

  after :all do
    rad.mode = :test, true

    remove_constants %w(
      MockFlashContext
      FlashTestRenderCaller
      FlashTestHelper
    )
  end

  def check_flash opt
    workspace = nil
    result = rad.http.call(Rad::Http::Request.stub_environment, check_flash: opt.to_openobject) do |c|
      c.call
      workspace = rad.workspace
    end

    workspace.before_request_done.should be_true
    workspace.request_done.should be_true
    workspace.after_request_done.should be_true
    workspace
  end

  it "flash should be extracted from session if there's any" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'html'
        workspace.request.session['flash'] = {info: 'Ok'}.to_json
      },
      request: lambda{|context|
        context.flash.info.should == "Ok"
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should be_nil
      }
    )

    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'html'
      },
      request: lambda{|context|
        context.flash.info.should be_nil
      }
    )
  end

  it "flash should be seen in the same request" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'html'
      },
      request: lambda{|context|
        context.flash.info = "Ok"
        context.flash.info.should == "Ok"
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should be_nil
      }
    )
  end

  it "flash with :redirect should be saved for next request in session" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'html'
      },
      request: lambda{|context|
        context.flash.info = "Ok"
        context.flash.info.should == "Ok"
        context.redirect_to '/'
        context.flash.info.should be_nil
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should == {info: 'Ok'}.to_json
      }
    )
  end

  it "AJAX ('js' format) flash should be displayed in the same request" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'js'
      },
      request: lambda{|context|
        context.flash.info = "Ok"
        context.flash.info.should == "Ok"
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should be_nil
      }
    )
  end

  it "flash with AJAX redirect ('js' format) should be saved for next request in session" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'js'
      },
      request: lambda{|context|
        context.flash.info = "Ok"
        context.flash.info.should == "Ok"
        context.redirect_to '/'
        context.flash.info.should be_nil
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should == {info: 'Ok'}.to_json
      }
    )
  end

  it "multiple messages with non-AJAX request" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.request.session['flash'] = {info: 'Ok'}.to_json
      },
      request: lambda{|context|
        context.flash.error = "Error"
        context.flash.error.should == "Error"

        context.flash.info.should == 'Ok'
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should be_nil
      }
    )

    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'js'
        workspace.request.session['flash'] = {info: 'Ok'}.to_json
      },
      request: lambda{|context|
        context.flash.error = "Error"
        context.flash.error.should == "Error"
        context.redirect_to '/'
        context.flash.error.should be_nil

        context.flash.info.should == 'Ok'
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should == {error: 'Error'}.to_json
      }
    )
  end

  it "multiple messages with AJAX request" do
    check_flash(
      before_request: lambda{|workspace|
        workspace.params.format = 'js'
        workspace.request.session['flash'] = {info: 'Ok'}.to_json
      },
      request: lambda{|context|
        context.flash.error = "Error"
        context.flash.error.should == "Error"

        context.flash.info.should == 'Ok'
      },
      after_request: lambda{|workspace|
        workspace.request.session['flash'].should be_nil
      }
    )
  end

end