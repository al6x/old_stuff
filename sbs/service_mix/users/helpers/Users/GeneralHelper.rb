module GeneralHelper
  # [
  # ['Users', user_path],
  # ['Roles']
  # ]
  #
  def breadcrumb
    Array(@breadcrumb)
	end
	
	
	def main_menu
    @@menu ||= [
      [:home, url_for(Pages, :all)],
      [:accounts, url_for(Accounts, :all), :global_administration],
      [:users, url_for(Users, :all)],
    ]
    
    unless @active_menu.blank?
      (@@menu.collect do |key, link, permission|
        unless permission and !can?(permission)
          [t(key), link, key == @active_menu]
        else
          nil
        end
      end).compact
    else
      []
    end
  end
end