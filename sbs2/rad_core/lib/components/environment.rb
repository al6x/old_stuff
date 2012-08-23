rad.register :environment do
  rad.logger.info "RAD started in #{rad.mode} mode"
  Rad::Environment.new
end