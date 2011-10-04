register_wiget "Layout" do
    v = View.new
    a1 = v.add :a1, :string_edit
    a2 = v.add :a2, :string_edit
    
    root = v.add :root, :box, :title => "Properties", :style => "border padding float"
    root.add a1
    root.add a2		
    v.root = root
    
    l = View.new
    
    left = l.add :left, :wrapper, :component => Tools::Stub
    right = l.add :right, :wrapper, :component => Tools::Stub
    top = l.add :top, :wrapper, :component => Tools::Stub
    bottom = l.add :bottom, :wrapper, :component => Tools::Stub
    center = l.add :center, :wrapper, :component => :view
    
    root = l.add :layout, :border, :padding => true
    root.add :left, left
    root.add :right, right 
    root.add :top, top
    root.add :bottom, bottom
    root.add :center, center
    l.root = root
    
    Extension.bafter_object = lambda do
      Scope[Controller].view = v
      Scope[Window].layout = l
    end
    
    Spec::Adapter.new				
  end