class Controllers::Accounts < Controllers::Saas
  before :require_global_admin

  def all
    accounts = Models::Account.sort_by(:name).paginate(params).all
    accounts.to_rson :protected
  end

  def read
    Models::Account.by_name!(params[:id]).to_rson :protected
  end

  def create
    account = Models::Account.new params
    account.save
    account.to_rson :protected
  end

  def update
    account = Models::Account.by_name! params[:id]
    account.set(params).save
    account.to_rson :protected
  end

  def delete
    account = Models::Account.by_name! params[:id]
    account.delete
    account.to_rson :protected
  end

  protected
    def require_global_admin
      access_denied! unless user.global_admin?
    end
end