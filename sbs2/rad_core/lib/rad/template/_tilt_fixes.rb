module Tilt
  class Template
    # Tilt complies about not thread-safe require, disabling it.
    def require_template_library(name)
      require name
    end
  end
end

# # Tilt::HamlTemplate.inspect causes error, fixin it.
# class Tilt::HamlTemplate
#   def inspect
#     "#<Tilt::HamlTemplate:#{object_id} ...>"
#   end
# end
#
# # Tilt::HamlTemplate.inspect causes error, fixin it.
# # class Haml::Buffer
# #   def inspect
# #     "#<Tilt::Buffer:#{object_id} ...>"
# #   end
# # end