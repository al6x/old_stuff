class Controllers::Users < Controllers::Saas
  prepare_model Models::User, finder: :by_name!, only: [:read, :update, :add_role, :delete_role]

  def all
    users = Models::User.sort_by(:name).paginate(params).all
    users.to_rson :public
  end

  def read
    @user.to_rson :public_full
  end

  def update
    access_denied unless @user == rad.user or rad.user.admin?

    @user.set(params).save
    @user.to_rson :public_full
  end

  def add_role
    require_permission "manage_#{params[:role]}s"

    @user.roles.add params[:role]
    @user.save!
    @user.to_rson :public_full
  end

  def delete_role
    require_permission "manage_#{params[:role]}s"

    @user.roles.delete params[:role]
    @user.save!
    @user.to_rson :public_full
  end
end