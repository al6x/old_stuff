# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe "Commentable Wiget" do
#   controller_name :commentable_wiget
#   integrate_views
#   
#   before :each do
#     SETTING.services![:test_service] = {
#       :callbacks => "http://localhost:3001/service_mix_callbacks"
#     }
#         
#     @secure_params = {
#       :service => :test_service,
#     }
#     
#     @json_params = {  
#       :resource => {
#         :resource_id => 1, 
#         :resource_type => "Post",
#       }
#     }
#         
#     @params = {
#       :l => :en,
#       
#       :secure_params => @secure_params,
#     }
#     
#     ServiceMix::CallbackCaller.stub_result = {}
#     
#     @user = Factory.build :user
#     login_as User.anonymous
#     # set_account Factory.create(:account)
#     set_space Factory.create(:space)
#   end
#   
#   it "Should display comments && shouldn't allow to comment anonymous" do
#     resource = Factory.create :resource, :resource_id => 1
#     comment = Factory.create :comment, :user => @user, :resource => resource
#     
#     @json_params[:resource] = {
#       :resource_id => resource.resource_id, 
#       :resource_type => resource.resource_type,
#     }
#     
#     @params[:json_params] = {0 => @json_params}.to_json
#     
#     post :index, @params
#     
#     response.should be_success
#     
#     result = JSON.parse response.body
#     result.should == { "0"=> {
#       "can_view" => true, "cant_comment_cause" => "Login to comment", "can_comment"=>false,
#       "comments" => [{"text"=>"Comment 1", "username" => @user.name}]
#     }}
#   end
#   
#   it "should not allow to comment anonymous" do
#     @json_params[:text] = "Some text"
#     @params[:json_params] = @json_params.to_json
#     
#     post :create, @params
#     
#     response.should be_success
#   
#     result = JSON.parse response.body
#     result.should == {"error" => "Login to comment"}
#     
#     Comment.count.should == 0
#   end
#   
#   it "should be able to comment" do
#     @json_params[:text] = "Some text"
#     @params[:json_params] = @json_params.to_json
#     
#     login_as @user
#     post :create, @params
#     
#     response.should be_success
#   
#     result = JSON.parse response.body
#     result.should == {"info" => "Comment created"}
#     
#     Comment.count.should == 1
#     c = Comment.first
#     c.text.should == 'Some text'
#     c.resource.resource_id.should == @json_params[:resource][:resource_id].to_s
#     c.resource.resource_type.should == @json_params[:resource][:resource_type]
#   end
# end