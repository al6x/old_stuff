ActionController::Routing::Routes.draw do |map|
  map.connect '/', :controller => 'multitenant/pages'
  
  map.global_persistent_params :l #, :s
  # map.global_path_prefix :s
  
  # 
  # Authentication
  # 
  map.signup "/signup", :controller => 'multitenant/identities', :action => :enter_email_form
  map.login "/login", :controller => 'multitenant/sessions', :action => :login
  map.logout "/logout", :controller => 'multitenant/sessions', :action => :logout
  
  # map.resource :session, :controller => "multitenant/sessions"
  # map.connect "/sessions", :controller => 'multitenant/sessions', :action => :create
  
  map.resources :identities, :controller => "multitenant/identities", 
    :collection => {
      :enter_email_form => :get, :enter_email => :post,
      :finish_email_registration_form => :get, :finish_email_registration => :post,
      
      :finish_open_id_registration_form => :get, :finish_open_id_registration => :post,
      
      :forgot_password_form => :get, :forgot_password => :post,
      :reset_password_form => :get, :reset_password => :post,
      :update_password_form => :get, :update_password => :post,
      # :activate => :get,
    }
    
  map.resources :users, 
    :member => {
      :add_role => :post,
      :remove_role => :post
    }

  # 
  # Wigets
  # 
  # map.with_options(:namespace => "wigets") do |wigets|
  #   # wigets.resources :votable_wigets
  #   # wigets.resources :commentable_wigets
  #   wigets.resources :folders, :collection => {:create_file => :get, :destroy_file => :delete, :destroy_folder => :delete}
  # end
  
  # 
  # Administration
  # 
  map.resources :accounts, :controller => "multitenant/accounts" do |account|
    account.resources :spaces
  end
  
  # accounts.resources :spaces
  # 
  # map.resources :spaces do |spaces|
  #   spaces.resources :permissions
  # end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
