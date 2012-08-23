# TODO3 'unite this with SaaS '
module General
  def main_menu
    @@menu ||= [
      # [:home, all_pages_path],
      # [:accounts, all_accounts_path, :global_administrate],
      [:users, all_profiles_path],
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