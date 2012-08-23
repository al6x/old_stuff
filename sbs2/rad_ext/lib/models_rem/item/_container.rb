class Models::Item
  attr_accessor :dependent
  def dependent?; !!dependent end
  def independent?; !dependent? end
  def independent!; remove_instance_variable :@dependent end
  def dependent!; self.dependent = true end

  # TODO2 fix it.
  # field :dependent, type: Boolean, default: false # Indicates wheter or not Item depends on Container
  # has_many :containers, class_name: 'Models::Item', foreign_key: :item_ids
  #
  # CONTAINER_INHERITABLE_ATTRIBUTES = %w(owner_name viewers collaborators)
  # def inherit_container_attributes container, attributes = CONTAINER_INHERITABLE_ATTRIBUTES
  #   attributes.each{|attr| send "#{attr}=", container.send(attr)}
  # end
  #
  # # serches independent container for this item (used in search)
  # def independent_container
  #   unless independent_container = cache[:independent_container]
  #     if independent?
  #       independent_container = self
  #     else
  #       independent_container = containers.first
  #       raise "this dependent item dosn't have container!" unless independent_container
  #     end
  #     cache[:independent_container] = independent_container
  #   end
  #   independent_container
  # end
end