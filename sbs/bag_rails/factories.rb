Factory.define :page, class: 'Page', parent: :item do |p|
  p.name "Page"
end

Factory.define :task, class: 'Task', parent: :item do |o|
  o.name "Task"
end

Factory.define :folder, class: 'Folder', parent: :item do |o|
  o.name "Folder"
end

Factory.define :list, class: 'List', parent: :item do |o|
  o.name "List"
end
