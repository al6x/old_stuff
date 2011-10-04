# # Methods added to this helper will be available to all templates in the application.
# module ApplicationHelper
#   def main_menu
#     @@menu ||= [
#       [:home, url_for(:controller => 'multitenant/pages')],
#       [:accounts, accounts_path, :global_administration],
#       [:users, users_path],
#     ]
#     
#     unless @active_menu.blank?
#       (@@menu.collect do |key, link, permission|
#         unless permission and !can?(permission)
#           [t(key), link, key == @active_menu]
#         else
#           nil
#         end
#       end).compact
#     else
#       []
#     end
#   end
# end
