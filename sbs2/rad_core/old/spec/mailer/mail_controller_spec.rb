require 'spec_helper'

describe "MailerController" do
  with_view_path "#{spec_dir}/views"

  isolate :conveyors

  before{load 'rad/profiles/mailer.rb'}

  after :all do
    remove_constants %w(
      ExplicitBodySpec
      BodyTemplateSpec
      CopyParamsSpec
    )
  end

  def common_letter
    {from: "john@mail.com", to: "ben@mail.com", subject: "hi there"}.to_openobject
  end

  describe "building letter" do
    it "shouldn't render view if body explicitly specified" do
      class ::ExplicitBodySpec
        inherit Rad::Mailer::MailerController

        def signup model
          @from, @to, @subject = model.from, model.to, model.subject
          @body = "Hello Ben, signup notification."
        end
      end

      letter = ExplicitBodySpec.signup(common_letter.merge(body: 'Hello Ben, signup notification.'))
      letter.to_hash.to_openobject.should == common_letter.merge(body: 'Hello Ben, signup notification.')
    end

    it "should use template for body" do
      class ::BodyTemplateSpec
        inherit Rad::Mailer::MailerController

        def signup model, name
          @name = name
          @from, @to, @subject = model.from, model.to, model.subject
        end
      end

      letter = BodyTemplateSpec.signup(common_letter, "Ben")
      letter.to_hash.to_openobject.should == common_letter.merge(body: 'Hello Ben, signup notification.')
    end

    it "should copy workspace variables from current :cycle (from error, all checks important, don't delete anything!)" do
      class ::CopyParamsSpec
        inherit Rad::Mailer::MailerController

        def signup model
          @from, @to, @subject = model.from, model.to, model.subject
          @body = "language: #{params.l}, key: #{workspace.key}, space: #{rad.space}"
        end
      end

      rad.register :space, scope: :cycle

      letter = nil
      rad.activate :cycle, {} do
        rad.space = 'space'
        w = rad.workspace = Rad::Conveyors::Workspace.new
        w.key = 'value'
        w.params = Rad::Conveyors::Params.new
        w.params.l = 'ru'

        letter = CopyParamsSpec.signup(common_letter)
      end

      letter.to_hash.to_openobject.should == common_letter.merge(body: 'language: ru, key: value, space: space')
    end
  end

  it "delivering" do
    letter = Rad::Mailer::Letter.new common_letter.merge(body: "some text")
    letter.deliver
    letter.deliver

    sent_letters.should == [letter, letter]
  end
end