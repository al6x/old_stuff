require 'rails_ext/basic'

require 'rails_ext/micelaneous/safe_hash'
require 'rails_ext/micelaneous/config_files'

require 'rails_ext/micelaneous/defer_static_javascripts'
require 'rails_ext/hacks/defer_static_javascripts'

require 'rails_ext/micelaneous/email_config'

require 'rails_ext/micelaneous/rails_require'

require 'rails_ext/micelaneous/create_public_symlinks'

require 'addressable/uri'
require 'rails_ext/micelaneous/addressable_uri'
::Uri = Addressable::URI