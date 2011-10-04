require 'kit/factories'
require 'users/factories'

Factory.define :product, class: 'Models::Product', parent: :item do |p|
  p.sequence(:name){|i| "product_#{i}"}
  p.text "cool product"
end

Factory.define :order, class: 'Models::Order' do |o|
  o.name "Alex"
  o.phone "8 920 456 78 31"
end