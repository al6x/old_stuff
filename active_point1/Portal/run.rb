require 'ActivePoint/require'

ActivePoint.run \
:directory => "./../data",
:port => 8080,
:initialize => lambda{},
:default_object => 'Blog',
:plugins => [Portal::Blog],
:cache => "ObjectModel::Tools::NoCache"