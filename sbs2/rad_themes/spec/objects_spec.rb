require "spec_helper"

%w(default simple_organization).each do |theme|
  describe "Objects (#{theme})" do
    set_controller Rad::Face::Demo::Objects
    
    [:items, :folder, :list, :page, :selector, :user].each do |action|    
      it action do
        wcall action, theme: theme
      end
    end
  end
end