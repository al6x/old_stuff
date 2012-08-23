namespace :assets do
  require 'rad'

  desc "Copy assets to public folder"
  task copy_to_public: :environment do
    rad.assets.copy_to_public!
  end
end