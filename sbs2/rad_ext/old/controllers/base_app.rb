class BaseApp < Controllers::Base
  inherit Helpers::Kit::ControllerHelper

  helper Helpers::Kit::Authorization, Helpers::Kit::Captcha, Helpers::Kit::Pagination

  def prepare_general_params
    if params._tags
      @selected_tags = params._tags.split('-').select{|tag| Models::Tag.valid_name?(tag)}
    else
      @selected_tags = []
    end
    @selected_tags.freeze
    @selected_tags
  end
  before :prepare_general_params
  attr_reader :selected_tags
  helper_method :selected_tags
end