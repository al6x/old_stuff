require File.dirname(__FILE__) + '/../spec_helper'

CORE_CASES = %w{aspects basic folder items list page selector}  
SPECIAL_CASES = %w{user style}

THEME_LAYOUTS = {
	:default => [[:home, :default], [:style, :default], [:blog, :default], [:post, :default]],
	:simple_organization => [[:home, :home], [:style, :default], [:blog, :default], [:post, :default]]
}

describe "Common Interface" do
  controller_name "theme"
  integrate_views
  
  it "should display general help page" do
    get :help
    response.should be_success
  end
end

AbstractInterface.available_themes.each do |theme_name|
  describe "'#{theme_name}' theme" do
    controller_name 'theme'
    integrate_views
  
    (CORE_CASES + SPECIAL_CASES).each do |action_name|
      it "should display '#{action_name}'" do
        get action_name, :_theme => theme_name
        response.should be_success
      end
    end
  
    it "should display help page for #{theme_name} theme" do
      get :help, :_theme => theme_name
      response.should be_success      
    end
  end
  
  describe "'#{theme_name}' Theme for Site" do
    controller_name 'theme_site'
    integrate_views
    
    THEME_LAYOUTS[theme_name.to_sym].each do |action_name, ltemplate|
      it "should display #{action_name}" do
        get action_name, :_theme => theme_name, :_layout_template => ltemplate
        response.should be_success
      end
    end
  end
end