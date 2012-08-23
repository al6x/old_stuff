# Extensions for MongoMapper

## Simultaneous use of multiple databases

``` ruby
MongoMapper.db_config = {
  'default' => {'name' => "default_test"}
  'global' => {'name' => 'global_test'},      
}
MongoMapper.database = MongoMapper.databases[:default].name

# Comment will be connected to :default database
module Comment
  belongs_to :user
end

# User will be connected to :global database
module User
  use_database :global
  
  has_many :comments
end
```
    
## Migrations

Please see **samples/migration.rb** for full example.

``` ruby
# Works with multiple databases, support versions
Migration.define :default, 1 do |m|
  m.up{Sample.create name: 'name'}
  m.down{Sample.destroy_all}
end

# Tell it database and version, and it's smart enough to figure out all needed :up or :down
Migration.update(:default, 1)
```
    
## Custom Scope

:with_scope, :default_scope, :with_exclusive_scope, see spec for details.
    
## Counter Cache

``` ruby
class Comment
  belongs_to :post, counter_cache: true
end

Post.comments_count
```
    
## Attribute Converters

For editing complex objects in forms:

``` ruby
class Post
  key :tags, Array, as_string: :line
end

@post.tags_as_string = "personal, article"
@post.tags                                  # => ['personal', 'article']
@post.tags_as_string                        # => "personal, article"
```
    
## Handy upserts

``` ruby
@post.upsert! :$inc => {comments_count: 1}
```
    
## CarrierWave integration

File attachments (stored on File System, S3, MongoDB-GridFS)

``` ruby
class User
  file_key :avatar, AvatarUploader
end
```
    
## More

Please see specs.

# Installation

``` bash
gem install 'mongo_mapper_ext'
```

``` ruby    
require 'mongo_mapper_ext/mongo_mapper'
    
# support for CarrierWave is optional
# require 'mongo_mapper_ext/carrier_wave'
```

# Bugs & Questions

Please feel free to add bugs and questions to the project (see Issues tab).

# License

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.