class Tasks < Items  
  prepare_model Task, finder: :by_slug!, only: %w(edit update state destroy)
  
  def show
    @task = Task.by_slug params.id
    respond_to do |f|
      if @task
        require_permission :view, @task
        
        f.html{@html_title = @task.name}
        f.json{render json: @task}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end

  def new
    require_permission :create
    @task = Task.new
    
    respond_to do |f|
      f.js{old_render_action :new}
      f.json{render json: @task}
    end
  end
  
  def create
    require_permission :create
    @task = Task.new params.task
    
    respond_to do |f|
      if save_and_add_to_container_if_needed @task
        flash.info = t :task_created
        
        f.js{standalone? ? redirect_to(show_task_path(@task)) : old_render_action(:update)}
        f.json{render json: @task}
      else
        f.js{old_render_action :new, :edit}        
        f.json{render json: {errors: @task.errors}, status: :failed}
      end
    end
  end
  
  def edit
    require_permission :update, @task
    
    respond_to do |f|
      f.js{old_render_action :edit}
    end
  end
  
  def update
    require_permission :update, @task
    
    respond_to do |f|
      if @task.update_attributes params.task
        flash.info = t :task_updated
        
        f.js{old_render_action :update}
        f.json{render :ok}
      else
        f.js{old_render_action :edit}
        f.json{render json: {errors: @task.errors}, status: :failed}
      end
    end
  end
  
  def destroy    
    require_permission :destroy, @task
    @task.destroy
    flash.info = t :task_deleted
    
    respond_to do |f|
      f.js{standalone? ? redirect_to(default_path) : old_render_action(:destroy)}
      f.json{render :ok}
    end
  end
    
  def state
    require_permission :update, @task
    event = params.event
    
    @task.state_events.collect{|e| e.to_s}.must.include event
    @task.send event
    
    @task_finished = @task.finished? and @task.state_changed?
    
    respond_to do |f|
      if @task.save        
        flash.info = t :state_updated

        f.js{old_render_action :refresh}
        f.json{render :ok}
      else
        flash.error = t :failed
        
        f.js{old_render_action :refresh}
        f.json{render :failed}
      end
    end    
  end
end