# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe "Permissions" do
#   controller_name :permissions
#   integrate_views
# 
#   before :each do    
#     set_space Factory.create(:space)
#     
#     @user = Factory.create :user
#     @admin = Factory.create :admin
#     login_as @admin
#   end
#   
#   it "should display list of users" do    
#     get :index, :space_id => Space.current.id
#     response.should be_success
#   end
#     
#   it "should display edit dialog for user" do
#     get :edit, :space_id => Space.current.id, :id => @user.id, :format => :js
#     response.should be_success
#   end
#   
#   it "should update roles" do
#     put :update, :space_id => Space.current.id, :id => @user.id, :format => :js, :user => {:space_roles_as_string => "a, b"}
#     response.should be_success
#     @user = @user.reload
#         
#     @user.space_roles.sort.should == ['a', 'b']
#     
#     SpaceUserProfile.all.all?{|ur| ur.space == Space.current}.should be_true
#   end
#   
#   it "should delete roles" do    
#     @user.space_roles_as_string = 'a, b'
#     @user.save!
#     @user.update_space_roles
#     @user = @user.reload
#     @user.space_roles.sort.should == ['a', 'b']
#     
#     put :update, :space_id => Space.current.id, :id => @user.id, :format => :js, :user => {:space_roles_as_string => "a"}
#     response.should be_success
#     
#     @user = @user.reload
#     @user.space_roles.should == ["a"]
#     SpaceUserProfile.all.all?{|ur| ur.space == Space.current}.should be_true
#   end
# end