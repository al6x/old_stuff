Rails.development{RailsExt.create_public_symlinks!}

# we can load it only after globalize2 plugin will be loaded
require 'rails_ext/micelaneous/i18n_helper'