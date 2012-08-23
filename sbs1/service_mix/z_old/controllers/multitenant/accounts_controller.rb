class Multitenant::AccountsController < Multitenant::MultitenantController
  require_permission :global_administration
  
  persist_params
  
  layout 'multitenant'
  
  # def show
  #   @account = Account.find params[:id]
  #   @title = @account.name
  # end
  
  def index
    @accounts = Account.all
  end
  
  def new
    @account = Account.new
    render_action :edit
  end
  
  def create
    @account = Account.new params[:account]
    @account.name = params[:account][:name]
    if @account.save
      flash[:info] = t :account_created
      render_action :create
    else
      render_action :edit
    end
  end
  
  def edit
    @account = Account.find params[:id]
    render_action :edit
  end
  
  def update
    @account = Account.find params[:id]
    
    if @account.update_attributes params[:account]
      @account = @account.reload
      flash[:info] = t :account_updated
      render_action :update
    else
      render_action :edit
    end
  end
  
  def destroy
    @account = Account.find params[:id]
    @account.destroy
    flash[:info] = t :account_deleted
    render_action :destroy
  end

  active_menu{:accounts}
end