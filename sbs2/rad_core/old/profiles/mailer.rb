rad.conveyors.mail do |mail|
  mail.use Rad::Mailer::Processors::LetterBuilder

  mail.build!
end