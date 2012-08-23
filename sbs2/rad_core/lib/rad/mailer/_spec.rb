RSpec.configure do |config|
  config.before do
    rad.mailer.sent_letters.clear if rad.mailer?
  end
  config.after do
    rad.mailer.sent_letters.clear if rad.mailer?
  end
end

# This allows us to load Mailer lazily, only if it's used.
rad.after :mailer do |mailer|
  mailer.class.class_eval do
    def sent_letters
      @sent_letters ||= []
    end

    def deliver letter
      sent_letters << letter
    end
  end
end