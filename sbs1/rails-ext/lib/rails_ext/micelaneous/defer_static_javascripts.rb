ActionController::Base.class_eval do
  def self.defer_static_scripts
    before_filter :defer_static_scripts
  end
  
  def defer_static_scripts
    Thread.current[:deferred_static_scripts_called] = false
    Thread.current[:defer_static_scripts] = (request.xhr? or request.format == 'js') ? false : true
  end
  
  def self.defer_static_scripts?
    !!Thread.current[:defer_static_scripts]
  end
end

ActionView::Base.class_eval do
  def defer_static_scripts?
    ActionController::Base.defer_static_scripts?
  end
      
  def initialize_deferred_static_scripts
    return "" unless defer_static_scripts?
    not_deferred_static_script do
      javascript_tag "var deferred_static_scripts = [];"
    end
  end
  
  def not_deferred_static_script &block
    before = Thread.current[:defer_static_scripts]
    begin
      Thread.current[:defer_static_scripts] = false
      block.call
    ensure
      Thread.current[:defer_static_scripts] = before
    end
  end
  
  def call_deferred_static_scripts
    return "" unless defer_static_scripts?
    Thread.current[:deferred_static_scripts_called] = true
    content = <<END
$.each(deferred_static_scripts, function(){this()});
deferred_static_scripts = [];
END
    not_deferred_static_script do
      javascript_tag content
    end
  end
  
end