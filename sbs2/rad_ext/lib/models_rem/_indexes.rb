# TODO2 apply these indexes (and don't forget to add space_id prefix).

Models::Item.collection.instance_eval do
  create_index [[:_class, 1]]
  create_index [[:name, 1]], unique: true
  create_index [[:owner_name, 1]]
  create_index [[:slug, 1]], unique: true
  create_index [[:state, 1]]
  create_index [[:tags, 1]]
  create_index [[:created_at, 1]]
  create_index [[:updated_at, 1]]
  create_index [[:viewers, 1]]
end

Models::Comment.collection.instance_eval do
  create_index [[:item_id, 1]]
end

Models::SecureToken.collection.instance_eval do
  create_index [[:token, 1]], unique: true
  create_index [[:expires_at, 1]]
  create_index [[:user_id, 1]]
end

Models::Tag.collection.instance_eval do
  create_index [[:name, 1]], unique: true
  create_index [[:count, 1]]
end
