# 
# Processor
# 
class Rad::Processors::PrepareAutenticityToken < Rad::Conveyors::Processor      
  def call        
    if rad.http.session
      request = workspace.request.must_be.defined
      params = workspace.params.must_be.defined
          
      token = request.session['authenticity_token']

      if token.blank? and request.get? and
        token = generate_authenticity_token
        request.session['authenticity_token'] = token
      end              
    end
    
    next_processor.call
  end

    
  protected
    def generate_authenticity_token
      ActiveSupport::SecureRandom.base64(32)
    end
end


# 
# Controller
# 
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
  def authenticity_token 
    @authenticity_token
  end

  alias_method :form_tag_without_at, :form_tag
  def form_tag *args, &b    
    form_tag_without_at *args do
      concat(hidden_field_tag('authenticity_token', authenticity_token) + "\n") if authenticity_token
      b.call if b
    end
  end
end