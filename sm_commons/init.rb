require 'service_mix'
require 'sm_commons/role'


# 
# Paperclip
# 
require 'mime/types'
require 'paperclip/callbacks'
require 'paperclip/integration'
require 'paperclip/mime'
require 'paperclip/extensions'
require 'paperclip/validations'


# 
# MongoMapper
# 
module SMPluginsAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::Multitenant
  end
end
MongoMapper::Document.append_inclusions(SMPluginsAddition)


# 
# Action Controller and View
# 
require 'action_controller/acts/authenticated'
require 'action_controller/acts/authenticated_master_domain'
require 'action_controller/acts/authorized'
require 'action_controller/acts/multitenant'
require 'action_controller/acts/sm_micelaneous'

require 'sm_commons/service_mix_helper'
require 'sm_commons/rails'


# 
# Locales
# 
dir = File.dirname __FILE__
I18n.load_path += Dir["#{dir}/lib/sm_commons/locales/**/*.{rb,yml}"]


# 
# Text Utils
# 
# require 'wikitext'

require 'sanitize'
require 'stringex'
require 'sm_commons/text_utils'