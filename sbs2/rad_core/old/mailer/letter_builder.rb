class LetterBuilder < Rad::Conveyors::Processor
  def call
    # prepare
    controller = workspace.controller.must.be_present
    raise "The controller #{controller} must be a Rad::Mailer::MailerController!" unless controller.is_a? Rad::Mailer::MailerController
    action_name = workspace.action_name = workspace.method_name

    # call
    controller.set! params: workspace.params, action_name: workspace.action_name
    content = controller.call action_name, *workspace.arguments

    controller.body = content unless content.blank?

    # letter
    workspace.letter = ::Rad::Mailer::Letter.new(
      from: controller.from,
      to: controller.to,
      subject: controller.subject,
      body: controller.body
    )
    workspace.letter.validate!

    next_processor.call if next_processor
  end

end