require 'spec_helper'

describe "Letter" do
  it 'smoke test' do
    letter = Rad::Letter.new from: "john@mail.com", to: "ben@mail.com", subject: "hi there", body: "it's jach"
    letter.deliver

    rad.mailer.sent_letters.should == [letter]
  end
end