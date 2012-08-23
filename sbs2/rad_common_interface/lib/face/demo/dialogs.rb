class Rad::Face::Demo::Dialogs < Rad::Face::Demo::Base
  def show; end
  
  def dialog_form; end
  def dialog
    logger.info "Sleeping for 1 second"
    sleep 1
    
    if params.valid
      render action: :dialog
    else
      render action: :dialog_form
    end          
  end
  
  def inplace_form; end
  def inplace
    logger.info "Sleeping for 1 second"
    sleep 1
    
    @text = params.text
  end
end