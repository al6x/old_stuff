class Wigets::FoldersController < Wigets::AbstractWigetsController
  Folder = Wigets::Folder
  CallbackCaller = ServiceMix::CallbackCaller
  
  def index
    raise 'tmp'
    # raise_user_error "Too big Collection" if json_params.size > 100
    # result = @behaviour.process_for_view json_params
    # render :json => result
  end

  def create_file
    item = Folder.create_item! params, json_params, secure_params
    callback = CallbackCaller.new service
    callback.call :update_folder, item.folder.to_hash
    render :json => {:info => t(:file_saved)}
  end

  def destroy_file
    # @behaviour.destroy_file! json_params
    render :json => {:info => t(:file_deleted)}
  end
  
  def destroy_folder
    @behaviour.destroy_folder! json_params
    render :json => {:info => t(:folder_deleted)}
  end
  
  
end