require 'spec_helper'

describe "Mailer" do
  it 'smoke test' do
    letter = {from: "john@mail.com", to: "ben@mail.com", subject: "hi there", body: "it's jach"}
    rad.mailer.deliver letter
    rad.mailer.deliver letter
    rad.mailer.sent_letters.should == [letter, letter]
  end
end