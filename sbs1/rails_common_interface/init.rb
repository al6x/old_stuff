require 'abstract_interface'

AbstractInterface.available_themes.push *%w{default simple_organization}
# AVAILABLE_LAYOUT_TEMPLATES = %w{default home dashboard}

# ['basic/dialog', 'basic/popup'].each{|t| AbstractInterface.dont_wrap_into_placeholder.add t}

AbstractInterface.plugin_name = 'common_interface'

AbstractInterface.generate_helper_methods \
  :aspects => %w{discussion comment controls details paginator tag_selector},
  :basic => %w{bottom_panel dialog divider inplace message more narrow navigation navigation_item popup text title top_panel tool},
  :components => %w{basic_list basic_list_item table table_row tabs tabs_item toolbar},
  :items => %w{folder list list_item note page user thumb line file selector}

ActionController::Base.class_eval do
  helper CommonInterfaceHelper
end

dir = File.dirname __FILE__
AssetPackager.add "#{dir}/asset_packages.yml", "#{dir}/public"