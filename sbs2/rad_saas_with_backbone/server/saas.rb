require 'saas/gems'

require 'mongo/model'
require 'mongo/model/integration/rad'

require 'rad_ext'

class Saas
  attr_writer :email, :bottom_text, :site_key
  attr_required :email, :bottom_text, :site_key

  # attr_accessor :avatars_path
  # attr_required :avatars_path
end