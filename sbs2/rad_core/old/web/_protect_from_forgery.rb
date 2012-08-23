#
# Processor
#
class Rad::Web::Processors::PrepareAutenticityToken < Rad::Conveyors::Processor
  def call
    if rad.http.session
      request = workspace.request.must.be_defined
      params = workspace.params.must.be_defined

      token = request.session['authenticity_token']

      if token.blank? and request.get?
        request.session['authenticity_token'] = rad.cipher.generate_token
      end
    end

    next_processor.call
  end
end


#
# Controller
#
module Rad::Controller::ForgeryProtector
  attr_reader :authenticity_token
  protected
    def protect_from_forgery
      if request.session
        sat = request.session['authenticity_token']

        raise "invalid authenticity token!" unless \
          request.get? or
          !request.from_browser? or
          (sat.present? and sat == params.authenticity_token)

        @authenticity_token = sat
      end
    end
end

Rad::Controller::Http.include Rad::Controller::ForgeryProtector

Rad::Controller::Http::ClassMethods.class_eval do
  def protect_from_forgery options = {}
    before :protect_from_forgery, options
  end
end


#
# View
#
Rad::Html::FormHelper.class_eval do
  attr_reader :authenticity_token

  alias_method :form_tag_without_at, :form_tag
  def form_tag *args, &b
    form_tag_without_at *args do
      concat(hidden_field_tag('authenticity_token', authenticity_token) + "\n") if authenticity_token
      b.call if b
    end
  end
end