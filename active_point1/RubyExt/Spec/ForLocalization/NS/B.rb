class B < A
  def message
    to_l("English")
  end

  def class_hierarchy_message
    to_l("Class Hierarchy English")
  end

  def namespace_hierarchy_message
    to_l("Namespace Hierarchy English")
  end

  def substitution
    value = 10
    to_l("English \#{value}", binding)
  end

  def not_localized
    to_l("English Not Localized")
  end
end
