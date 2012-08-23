require 'rspec_ext'
require 'rspec_ext/xhtml'

require 'rad'
require 'rad/spec'

rad.common_interface

shared_examples_for 'commons demo' do
  set_controller Rad::Face::Demo::Commons
    
  [:aspects, :basic, :forms, :style, :items].each do |action|    
    it action do
      wcall action, theme: @theme
    end
  end
end

shared_examples_for 'site demo' do
  set_controller Rad::Face::Demo::Sites
  
  [:home, :style, :blog, :post].each do |action|
    it action do
      wcall action.to_sym, theme: @theme, layout_template: @layouts[action]
    end
  end
end