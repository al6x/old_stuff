class Selectors < Items
  layout '/bag/layout'

  partials.hide :comments

  def show
    partials do
      show :search
      show :tags
    end

    respond_to do |f|
      if @model
        require_permission :view, @model

        @page, @per_page = (params.page || 1).to_i, Models::Item::PER_PAGE

        query = Models::Item.where(
          viewers: {_in: rad.user.major_roles},
          dependent: {_exists: false}
        ).sort([:created_at, -1]).paginate(@page, @per_page)

        tags = (@model.query + selected_tags).uniq
        query = query.where tags: {_all: tags} unless tags.empty?

        @model.items = query.all

        f.html{@html_title = @model.name}
        f.json{render json: @model}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end

  def update
    require_permission :update, @model

    respond_to do |f|
      if @model.set(params.model).save
        flash.info = t :selector_updated

        f.js{reload_page}
        f.json{render :ok}
      else
        f.js{render action: :edit}
        f.json{render json: {errors: @model.errors}, status: :failed}
      end
    end
  end
end