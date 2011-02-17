#############################################################
#	Application
#############################################################

set :application, "service_mix"
set :deploy_to, "/apps/service_mix"
set :rails_env, "production"

#############################################################
#	Servers
#############################################################

set :user, "web"
set :domain, "saas4b.com"
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	Git
#############################################################
set :scm, :git
set :branch, "master"
# set :scm_user, 'bort'
# set :scm_passphrase, "PASSWORD"
set :repository, "git@github.com:alexeypetrushin/service_mix.git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1