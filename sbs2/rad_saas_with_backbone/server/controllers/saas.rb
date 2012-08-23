class Controllers::Saas
  inherit \
    Rad::Http::Controller,
    Controllers::Authorization,
    Controllers::PrepareModel
end