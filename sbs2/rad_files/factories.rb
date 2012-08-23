Factory.define :file, class: 'Models::File', parent: :item do |f|
  f.sequence(:file_file_name){|i| "File#{i}"}
  f.file_content_type 'jpg'
  f.file_file_size 25
end
