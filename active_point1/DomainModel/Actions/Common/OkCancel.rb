class OkCancel < CPView
  build_view do |v|
    form = v.add :form, :box, :padding => true
    v.root = form
    
    toolbar = v.add :toolbar, :flow, :floating => true, :padding => true, :highlithed => true
    form.add toolbar
    
    bok = v.add :ok, :button, :text => "Ok", :inputs => form, :action => lambda{v.on_ok_get.call if v.on_ok_get}
    toolbar.add bok

    bcancel = v.add :cancel, :button, :text => "Cancel", :action => lambda{v.on_cancel_get.call if v.on_cancel_get}
    toolbar.add bcancel
    
    text = v.add :text, :string_view
    form.add text
  end 
  
  def text= text
    self.values = {:text => text}
  end
  
  def on_ok_get; @on_ok end
    
    def on_cancel_get; @on_cancel end
  
  def on_ok &b
    @on_ok = b
  end
  
  def on_cancel &b
    @on_cancel = b
  end
end