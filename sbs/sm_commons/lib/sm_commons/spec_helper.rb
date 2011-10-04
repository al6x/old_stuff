require 'mongo_mapper_ext/spec_helper'

# 
# Mail
# 
def clear_mail
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries = []
end

def sent_letters
  ActionMailer::Base.deliveries
end

# 
# Routes
# 
def default_path
  SETTING.default_path!
end

# 
# User
# 
User.class_eval do
  def self.anonymous
    @anonymous ||= Factory.build :anonymous
  end
end

def login_as user
  User.current = user
  # controller.stub!(:current_user).and_return(user)
end

ActionController::Acts::AuthenticatedMasterDomain::InstanceMethods.class_eval do
  def prepare_current_user_for_master_domain_with_test
    prepare_current_user_for_master_domain_without_test if $do_not_skip_authentication
  end
  alias_method_chain :prepare_current_user_for_master_domain, :test
end
  
ActionController::Acts::Authenticated::InstanceMethods.class_eval do
  def prepare_current_user_for_slave_domain_with_test
    prepare_current_user_for_slave_domain_without_test if $do_not_skip_authentication
  end
  alias_method_chain :prepare_current_user_for_slave_domain, :test
  
end

# Account
# Account.class_eval do
#   def self.current 
#     @current ||= Factory.build :account, :name => 'test_account'
#   end
# end
# 
# def set_account account
#   Account.current = account
# end

def set_default_space
  account = Factory.create :account
  
  Account.current = account
  Space.current = account.spaces.first  
end

def set_space space
  if space
    Space.current = space
    Account.current = space.account
  else
    Space.current = nil
    Account.current = nil
  end
end





# begin
#   ActionController::Acts::Wiget::InstanceMethods.class_eval do
#     def check_permission_and_forgery
#       # do nothing
#     end
#   end
# rescue NameError
# end
warn 'dont forget to uncomment (fow wiget support)'




# 
# Encryption
# 
ServiceMix.class_eval do
  def self.encrypt message
    message
  end
  
  def self.decrypt message
    message
  end
end


# 
# Multitenancy
# 
# db_name = "#{SETTING.db_prefix!}_default_#{Rails.env}"
# global_db_name = "#{SETTING.db_prefix!}_global_#{Rails.env}"
# MongoMapper.database = db_name

module ActionController
  module Acts
    module Multitenant
      module InstanceMethods
        protected
  
          def select_account_and_space
            yield
          end
        
          def select_multitenant_database
            yield
          end
      end
    end
  end
end

# 
# Clear Database before each Spec
# 
# Spec::Runner.configure do |config|
#   config.before(:each) do
#     connection = MongoMapper.connection
#     [db_name, global_db_name].each do |dbn|
#       db = connection.db(dbn)
#       db.collection_names.each do |name|
#         db.collection(name).drop
#       end
#     end
#   end
# end