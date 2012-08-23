# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe "Votable Wiget" do
#   controller_name :votable_wiget
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
#       },
# 
#       :vote => {
#         :value => 1
#       }
#     }
#     
#     @params = {
#       :l => :en,
#       
#       :secure_params => @secure_params,
#       :json_params => @json_params.to_json
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
#   it "should check for can_vote? before create an one (from error)" do    
#     # Making this user already voted today
#     resource = Factory.create :resource, :resource_id => 1, :rating => 1
#     vote = Factory.create :vote, :user => @user, :resource => resource
#     
#     @json_params[:resource] = {
#       :resource_id => resource.resource_id, 
#       :resource_type => resource.resource_type,
#     }
#     
#     resource = resource.reload
#     
#     login_as @user
#     post :create, @params
#     
#     response.should be_success
#     
#     result = JSON.parse response.body
#     result.should == {"error"=>"You already voted today"}
#     
#     Resource.first.rating.should == 1
#   end
#   
#   it "should show 0 rating if new resource and should differentiate resources from different accounts" do
#     account = Factory.create :account, :name => 'anoter_account'
#     space = Factory.create :space, :account => account, :name => 'anoter_space'
#     resource = Factory.create :resource, :space => space, :rating => 10 # noise
#     
#     @json_params[:resource] = {
#       :resource_id => resource.resource_id, 
#       :resource_type => resource.resource_type,
#     }
#     @params[:json_params] = {0 => @json_params}.to_json
#     
#     get :index, @params
#     
#     response.should be_success
#   
#     result = JSON.parse response.body
#     result.size.should == 1
#     
#     result["0"].should == {"rating"=>0, "can_view"=>true, "rating_word"=>"votes", "can_vote"=>false, "cant_vote_cause"=>"Login to vote"}
#   end
#   
#   it "should show resource rating if resource exist" do
#     Factory.create :resource, :resource_id => 1, :rating => 10
#         
#     @params[:json_params] = {"0" => @json_params}.to_json
#     
#     login_as @user
#     get :index, @params
#     
#     response.should be_success
#     
#     result = JSON.parse response.body
#     result.size.should == 1
#     result["0"].should == {"rating"=>10, "can_view"=>true, "rating_word"=>"votes", "can_vote"=>true}
#   end
#    
#   it "should vote" do
#     login_as @user
#     post :create, @params
#     
#     response.should be_success
#     
#     result = JSON.parse response.body
#     result.should == {"info"=>"Rating updated"}
#     
#     Resource.count.should == 1
#     Resource.first.rating.should == 1
#   end 
#   
#   it "shouldn't vote if callbacks not responding or return error" do
#     ServiceMix::CallbackCaller.stub_result = {'error' => 'Some error'}
#     
#     login_as @user
#     
#     post :create, @params
#     
#     response.should be_success
#     
#     result = JSON.parse response.body
#     result.should == {"error"=>"Some error"}
#   end
# end