# Allow layout for RJS
ActionView::Template.send(:class_variable_set, :@@exempt_from_layout, Set.new)