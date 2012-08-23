require 'kit/factories'
require 'users/factories'

Factory.define :note, class: 'Models::Note', parent: :item do |n|
  n.sequence(:name){|i| "note_#{i}"}
  # n.text "Some text"
  n.original_text "Some text"
end

Factory.define :selector, class: 'Models::Selector', parent: :item do |s|
  s.view 'line'
end