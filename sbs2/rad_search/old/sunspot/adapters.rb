module Sunspot #:nodoc:
  module MongoMapper #:nodoc:
    # 
    # This module provides Sunspot Adapter implementations for MongoMapper
    # models.
    #
    module Adapters
      class MongoMapperInstanceAdapter < Sunspot::Adapters::InstanceAdapter
        # 
        # Return the primary key for the adapted instance
        #
        # ==== Returns
        # 
        # Integer:: Database ID of model
        #
        def id
          @instance.id
        end
      end

      class MongoMapperDataAccessor < Sunspot::Adapters::DataAccessor
        # options for the find
        attr_accessor :include, :select

        #
        # Set the fields to select from the database. This will be passed
        # to MongoMapper.
        #
        # ==== Parameters
        #
        # value<Mixed>:: String of comma-separated columns or array of columns
        #
        def select=(value)
          value = value.join(', ') if value.respond_to?(:join)
          @select = value
        end
        
        # 
        # Get one MongoMapper instance out of the database by ID
        #
        # ==== Parameters
        #
        # id<String>:: Database ID of model to retreive
        #
        # ==== Returns
        #
        # MongoMapper::Base:: MongoMapper model
        # 
        def load(id)
          @clazz.first(options_for_find.merge(id: id))
        end

        # 
        # Get a collection of MongoMapper instances out of the database by ID
        #
        # ==== Parameters
        #
        # ids<Array>:: Database IDs of models to retrieve
        #
        # ==== Returns
        #
        # Array:: Collection of MongoMapper models
        #
        def load_all(ids)
          @clazz.all(options_for_find.merge(id: ids))
        end
        
        private
        
        def options_for_find
          returning({}) do |options|
            options[:include] = @include unless @include.blank?
            options[:select]  =  @select unless  @select.blank?
          end
        end
      end
    end
  end
end
