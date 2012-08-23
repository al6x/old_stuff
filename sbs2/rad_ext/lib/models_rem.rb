require 'mongo/model'
require 'mongo/model/integration/rad'

require 'text_utils'

module Models
end

Mongo::Model.inherit \
  Models::TextProcessor, Models::Miscellaneous

rad.extension :mm_extensions