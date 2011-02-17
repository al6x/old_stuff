ActionView::Helpers::JavaScriptHelper.class_eval do
  def javascript_cdata_section_with_defer content
    if defer_static_scripts?
      unless Thread.current[:deferred_static_scripts_called]  
        content = <<END
deferred_static_scripts.push(function(){
  
#{content}

});
END
      end
    end
    
    javascript_cdata_section_without_defer content
  end
  alias_method_chain :javascript_cdata_section, :defer
end