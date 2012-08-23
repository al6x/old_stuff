rad.register_extension :email_verification_token do
  db :global
end

rad.register_extension :forgot_password_token do
  db :global
end

rad.register_extension :user_model do
  db :global
end