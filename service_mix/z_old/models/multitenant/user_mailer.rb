module Multitenant
  class UserMailer < ActionMailer::Base
  
    def email_verification token
      recipients token.email
      from SETTING.master_email!
      sent_on Time.now
      subject t(:email_verification_title, :host => SETTING.master_domain!)
      
      body \
        :host => SETTING.master_domain!,
        :url => finish_email_registration_form_identities_url(:host => SETTING.master_domain!, :token => token.token)
    end

    # def signup_notification user
    #   setup_email user
    #   @subject = t :email_registration_title, :name => user.name, :host => SETTING.master_domain!
    #   @body[:url] = url_for :host => SETTING.master_domain!, :controller => :identities, :action => :activate, :token => user.token
    #   @body[:host] = SETTING.master_domain!
    # end
    # 
    # def activation_notification user
    #   setup_email user
    #   @subject = t :email_activation_title, :name => user.name, :host => SETTING.master_domain!
    #   @body[:host] = SETTING.master_domain!
    # end

    
    def forgot_password token
      recipients token.user.email
      from SETTING.master_email!
      sent_on Time.now            
      subject t(:forgot_password_title, :name => token.user.name, :host => SETTING.master_domain!)
      
      body \
        :user => token.user,
        :url => reset_password_form_identities_url(:host => SETTING.master_domain!, :token => token.token)
    end
  end
end