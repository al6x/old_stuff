require 'spec_helper'

describe "Space" do
  with_models

  # Rejected.
  # it "values of :permissions and :default_viewers should depend on :access_type" do
  #   s = Models::Space.new
  #   s.custom_permissions = {'create' => ['special']}
  #   s.custom_viewers = ['special']
  #
  #   s.access_type.should == 'private'
  #   s.permissions.should == {}
  #   s.default_viewers.should == []
  #
  #   s.access_type = 'custom'
  #   s.permissions.should == {'create' => ['special']}
  #   s.default_viewers.should == ['special']
  # end

  # Rejected.
  # describe "Tags" do
  #   it "should build additional_menu based on tags" do
  #     home    = Factory.create :space, account: rad.account, name: 'home', space_tags: ['en'], space_home_tag: 'en', default_url: '/home'
  #     blog    = Factory.create :space, account: rad.account, name: 'blog', space_tags: ['en']
  #
  #     home_ru = Factory.create :space, account: rad.account, name: 'home-ru', space_tags: ['ru'], space_home_tag: 'ru', default_url: '/home_ru'
  #     blog_ru = Factory.create :space, account: rad.account, name: 'blog-ru', space_tags: ['ru']
  #
  #     other   = Factory.create :space, name: 'other'
  #
  #     [home, blog, home_ru, blog_ru, other].every.reload
  #
  #     home.additional_menu.should    == [['en', '/'],     ['ru', '/home_ru']]
  #     blog.additional_menu.should    == [['en', '/'],     ['ru', '/home_ru']]
  #     home_ru.additional_menu.should == [['en', '/home'], ['ru', '/']]
  #     blog_ru.additional_menu.should == [['en', '/home'], ['ru', '/']]
  #     other.additional_menu.should   == []
  #   end
  # end

  # Rejected
  # it "should delete all dependent items" do
  #   class Plane
  #     inherit Mongo::Model
  #     belongs_to_space
  #   end
  #
  #   plane = Plane.create!
  #
  #   rad.space.destroy
  #   plane.exist?.should be_false
  # end
end