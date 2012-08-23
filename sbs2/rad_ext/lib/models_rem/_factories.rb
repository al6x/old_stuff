factory.define :item, class: 'Models::Item' do |o|
  o.name = "item_#{factory.next :item_name}"
end

factory.define :comment, class: 'Models::Comment', parent: :item do |c|
  c.original_text = "Some text"
end