# asset_path
ActionView::Helpers::AssetTagHelper.class_eval do
  private
    def compute_public_path_with_global_prefix *args, &block
      tmp = ActionController::Base.relative_url_root
      begin
        ActionController::Base.relative_url_root = ActionController::Base._relative_url_root
        compute_public_path_without_global_prefix *args, &block
      ensure
        ActionController::Base.relative_url_root = tmp
      end
    end
    alias_method_chain :compute_public_path, :global_prefix
end

# 
# Recognition
# delete global_path_prefix from path before rails recognition
ActionController::Routing::RouteSet.send :class_eval do
  def recognize_path_with_global_prefix path, environment={}
    prefix_params = {}
    new_path = path.clone
    ActionController::Base.global_path_prefix.each do |name|
      new_path.gsub! /\A\/.+?#{GLOBAL_PATH_PREFIX_DELIMITER}#{name}/ do |value|
        prefix_params[name] = CGI.unescape value[1..-(name.size + GLOBAL_PATH_PREFIX_DELIMITER.size + 1)]
        ""
      end
    end
    params = recognize_path_without_global_prefix new_path, environment
    return params.reverse_merge prefix_params
  end
  alias_method_chain :recognize_path, :global_prefix
end
