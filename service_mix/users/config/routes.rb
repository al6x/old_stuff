crystal.routes do |c|
  c.named_route 'identities', Users::Identities
  c.named_route 'sessions', Users::Sessions
end