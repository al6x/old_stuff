class UsersController < ApplicationController  
  acts_as_multitenant
  
  prepare_model User, :finder => :find_by_name!, :only => [:show, :edit, :update, :add_role, :remove_role]
  
  # require_permission :view, :only => :show do
  #   @user
  # end
  
  def index
    @users = User.all
  end
  
  def show
  end
  
  
  require_permission :update_profile, :object => lambda{@user}, :only => [:edit, :update]
  def edit
  end
  
  def update
    access_denied if @user.anonymous? and !User.current.global_admin?
    if @user.update_attributes params[:user]
      flash[:info] = t :user_updated
      redirect_to :action => 'show'
    else
      render :edit
    end
  end  
  
  def add_role
    require_permission "add_#{params[:role]}_role"
    
    @user.add_role params[:role]
    @user.save!
    @user.reload
    flash[:info] = t :role_granted
    render_action :update_roles
  end
  
  def remove_role
    require_permission "remove_#{params[:role]}_role"
    
    @user.remove_role params[:role]
    @user.save!
    @user.reload
    flash[:info] = t :role_removed
    render_action :update_roles
  end
  
  active_menu{:users}
end
