class SpacesController < ApplicationController
  acts_as_multitenant
  
  require_permission :account_administration
  prepare_model Account, :id => :account_id
  
  persist_params
    
  def index
    @title = @account.name
    @spaces = @account.spaces
  end
  
  def new
    @space = Space.new
    render_action :edit
  end
  
  def create
    @space = Space.new params[:space].merge(:account => @account)    
    @space.name = params[:space][:name]
    if @space.save
      flash[:info] = t :space_created
      render_action :create
    else
      render_action :edit
    end
  end
  
  def edit
    @space = Space.find params[:id]
    render_action :edit
  end
  
  def update
    @space = Space.find params[:id]
    if @space.update_attributes params[:space]
      @space = @space.reload
      flash[:info] = t :space_updated
      render_action :update
    else
      render_action :edit
    end
  end
  
  def destroy
    @space = Space.find params[:id]
    raise_user_error t(:forbiden_to_delete_default_space) if @space.name == 'default'
    @space.destroy
    flash[:info] = t :space_deleted
    render_action :destroy
  end

  protected
    before_filter :set_account
    def set_account
      @account = Account.find params[:account_id]
    end
    
    before_filter :set_breadcrumb
    def set_breadcrumb
      @breadcrumb = [
        link_to(t(:accounts), accounts_path),
        @account.name
      ]
    end
end