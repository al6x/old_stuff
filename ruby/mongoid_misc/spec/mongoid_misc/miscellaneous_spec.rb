require 'mongoid_misc/spec_helper'

describe "Miscellaneous" do
  with_mongoid
  
  after(:all){remove_constants %w(UpsertSample AsStringSample TranslationCheck Article Post Namespace AliasTest)}    
  
  # describe "Database aliases" do
  #   it "basics" do
  #     Mongoid.set_database_aliases default: 'default_production', global: 'global_production'
  #   
  #     klass = class ::AliasTest
  #       include Mongoid::Document
  #     end
  #     
  #     klass.should_receive(:set_database).with('global_production')
  #     klass._set_database_alias :global
  #     
  #     -> {klass._set_database_alias :invalid_alias}.should raise_error(/unknown database alias/)
  #   end
  # end
    
  describe "i18n" do
    it "should translate error messages" do
      class ::TranslationCheck
        include Mongoid::Document

        field :name, default: String
        validates_uniqueness_of :name
      end

      TranslationCheck.destroy_all
      TranslationCheck.create! name: 'a'
      t = TranslationCheck.new name: 'a'
      t.should_not be_valid
      t.errors[:name].first.should =~ /already taken/
    end
  end
    
  describe "handy upsert" do
    class ::UpsertSample
      include Mongoid::Document
      
      field :counter, type: Integer, default: 1
    end  
    
    before do 
      @model = UpsertSample.create!
    end
  
    it "class upsert" do
      UpsertSample.upsert!({id: @model.id}, :$inc => {counter: 1})
      @model.reload
      @model.counter.should == 2
    end
  
    it "model upsert" do
      @model.upsert! :$inc => {counter: 1}
      @model.reload
      @model.counter.should == 2
    end
  end
  
  describe "model_name" do
    it "basic" do      
      class Article
        include Mongoid::Document
      end
      
      Article.model_name.should == "Article"
      Article.model_name "SuperArticle"
      Article.model_name.should == "SuperArticle"
    end
    
    it "by default should be initialized from class alias" do
      class ::Post
        include Mongoid::Document

        self.alias 'PostAlias'
      end
      
      module ::Namespace
        class Post
          include Mongoid::Document      
        end
      end
      
      Post.model_name.should == 'PostAlias'
      Namespace::Post.model_name.should == 'Post' # not the Namespace::Post
    end
  end
end