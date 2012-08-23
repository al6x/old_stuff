require "spec_helper"

{
  default: {
    product:  :default,
    products: :default
  },
  simple_organization: {
    product:  :default,
    products: :home
  }
}.each do |theme, meta|
  describe "Stores (#{theme})" do
    set_controller Rad::Face::Demo::Stores
    
    meta.each do |action, layout_template|              
      it action do
        wcall action, theme: theme, layout_template: layout_template
      end
    end
  end
end