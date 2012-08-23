require 'factory_girl'

Factory.define :comment, class: 'Models::Comment' do |o|
  o.text "some text"  
end

Factory.define :post, class: 'Models::Post' do |o|
  o.name "some name"
  o.text "some text"
end