# Preparing rad.
require 'rad'
rad.mode = :production unless rad.mode?

# Preparing application.
load "./init.rb"

# Assembling middleware.
use Rad::Assets::Middleware::Server # unless rad.production?
use Rad::Http::Middleware::Basic
use Rad::Http::Middleware::NoWww
run Saas::Http::Adapter.new