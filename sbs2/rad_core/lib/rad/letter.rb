class Rad::Letter
  inject :mailer

  attr_accessor :from, :to, :subject, :body

  def initialize properties
    properties.each do |k, v|
      send "#{k}=", v
    end
  end

  def validate!
    from || raise("letter :from not specified!")
    to || raise("letter :to not specified!")
    subject || raise("letter :subject not specified!")
    body || raise("letter :body not specified!")
  end

  def deliver
    validate!
    mailer.deliver self
  end

  def to_hash
    {from: from, to: to, subject: subject, body: body}
  end
end