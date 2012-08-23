class Rad::Mailer
  inject :logger

  def deliver letter
    letter = letter.to_hash
    logger.info "MAILER: delivering '#{rad.development? ? letter.inspect : letter[:subject]}'"

    if rad.production?
      require 'mail'
      ::Mail.new(letter).deliver!
    end

    nil
  end
end