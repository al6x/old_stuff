Models::User.collection.instance_eval do
  create_index [[:name, 1]], unique: true
  create_index [[:email, 1]], unique: true
  create_index [[:state, 1]]
  create_index [[:created_at]]
  create_index [[:updated_at]]
end

Models::Account.class_eval do
  create_index [[:name, 1]], unique: true
  create_index [[:domains]]
end

Models::Space.class_eval do
  create_index [[:name, 1]]
  create_index [[:account_id, 1]]
  create_index [[:space_tags, 1]]
end

# Models::Item.class_eval do
#   create_index [[:space_id, 1]]
# end