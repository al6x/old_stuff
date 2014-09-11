class SelectBase < CPView
  build_view do |v|
    form = v.add :form, :box, :padding => true
    v.root = form
    
    toolbar = v.add :toolbar, :flow, :floating => true, :padding => true, :highlithed => true
    form.add toolbar
    
    bok = v.add :ok, :button, :text => "Ok", :inputs => form, :action => lambda{v.metadata.perform_edit}
    toolbar.add bok

    bcancel = v.add :cancel, :button, :text => "Cancel", :action => lambda{v.metadata.cancel}
    toolbar.add bcancel
    
    attrs = v.add :attrs, :attributes
    form.add attrs
  end 
end