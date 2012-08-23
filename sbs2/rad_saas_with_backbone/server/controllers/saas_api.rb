class Controllers::SaasApi < Controllers::Saas
  def read
    user = rad.user
    space = rad.account.get_space(params[:id])

    if space
      {
        user:  user.to_rson(:public_full),
        space: space.to_rson(:public)
      }
    else
      {errors: "no space with '#{params[:id]}' name!"}
    end
  end
end