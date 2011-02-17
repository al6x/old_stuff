# Load mail configuration if not in test environment
if RAILS_ENV != 'test'
  filename = "#{RAILS_ROOT}/config/email.yml"
  if File.exist? filename
    email_settings = YAML::load(File.open(filename))
    ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
  end
end