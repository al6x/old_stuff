## Mongo Migrations

Migrations are framework-agnostic, You can use it with Mongoid, MongoMapper, or with just with bare Mongo driver.

    require 'mongo_migration'
    require 'mongo_migration/adapters/mongoid'
    
    # use existing adapter or define Your own, it has only 2 methods 
    # and about 10 lines of code (use Mongoid as a sample)
    adapter = Mongo::Migration::Mongoid.new
    
    # initialize migration
    Mongo.migration = Mongo::Migration.new adapter
    
    # configure migration by defining migration steps 
    # You can place all of them in one file or as different
    # files in one directory
    Mongo.migration.define 1 do |m|
      m.up do |db|
        # update Your models
        # User.create name: 'Bob'
        
        # or use db directly
        db.collection('users').insert({name: 'Bob'})
      end
      m.down{|db| db.collection('users').remove({name: 'Bob'})}
    end
        
    Mongo.migration.define 2 do |m|
      m.up{|db| db.collection('users').insert({name: 'John'})}
      m.down{|db| db.collection('users').remove({name: 'John'})}
    end
    
    # specify what version (it can be any version) do You need
    # and apply migration
    # You can call it directly or via Rake task
    Mongo.migration.update 2    
    adapter.database(:default).collection('users').find.count.should == 2
    
    # rollback to any version changes
    Mongo.migration.update 0
    adapter.database(:default).collection('users').find.count.should == 0
    
To see this code running go to spec.  

# Mongoid

## Attribute Converters

Handy shortcut to assign tags (Array) as a string with delimiters (there are also other converters for Lists, Hashes, Yaml):

    class Post    
      include Mongoid::Document
      
      field :tags, type: Array, default: [], as_string: :line
    end
    
    @post.tags_as_string = "personal, article"
    @post.tags                                  # => ['personal', 'article']
    @post.tags_as_string                        # => "personal, article"

## :counter_cache option

    class Comment
      belongs_to :post, counter_cache: true
    end
    
    Post.comments_count
    
## Handy upserts

    @post.upsert! :$inc => {comments_count: 1}
    
# Installation

    gem install 'mongoid_misc'
    
    require 'mongoid_misc'
        
    # support for CarrierWave is optional
    # require 'carrierwave_ext'

# License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.