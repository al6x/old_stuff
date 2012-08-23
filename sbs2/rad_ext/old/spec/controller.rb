Controllers::Base.class_eval do
  def prepare_current_user; end
end

Rad::Controller::Context.class_eval do
  def user_path name
    "/user/#{name}"
  end
end