require 'kit/factories'
require 'users/factories'


# Bag
Factory.define :note, class: 'Models::Note', parent: :item do |n|
  n.sequence(:name){|i| "note_#{i}"}
  # n.text "Some text"
  n.original_text "Some text"
end

Factory.define :selector, class: 'Models::Selector', parent: :item do |s|
  s.view 'line'
end


# Store
Factory.define :product, class: 'Models::Product', parent: :item do |p|
  p.sequence(:name){|i| "product_#{i}"}
  p.text "cool product"
end

Factory.define :order, class: 'Models::Order' do |o|
  o.name "Alex"
  o.phone "8 920 456 78 31"
end