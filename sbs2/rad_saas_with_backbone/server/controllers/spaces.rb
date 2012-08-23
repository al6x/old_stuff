class Controllers::Spaces < Controllers::Saas
  require_permission :administrate
  inject :account

  def all
    spaces = account.spaces
    spaces.to_rson :protected
  end

  def read
    space = account.get_space params[:id]
    space.to_rson :protected
  end

  def create
    space = Models::Space.new
    space.account = account
    space.set params
    account.spaces << space
    account.save
    space.to_rson :protected
  end

  def update
    space = account.get_space params[:id]
    space.set params
    account.save
    space.to_rson :protected
  end

  def delete
    space = account.get_space params[:id]
    account.spaces.delete space
    account.save
    space.to_rson :protected
  end
end