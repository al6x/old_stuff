# TODO

- eliminate 'include A::B::C', make it 'include C' (search for ::.*::)


+ introduce link_to! and some_path! to preserve state (rejected)
+ move rad.js from common_interface to rad_core
+ change class << self to metaclass_eval
+ update config.ru, take filename from caller instead of __FILE__
+ refactor using Micon components instead of 'include'
+ move Rad's Micon helpers to support
+ refactor rad.register to use scope: :application

# Articles
- Async Rails App http://www.slideshare.net/igrigorik/no-callbacks-no-threads-railsconf-2010 http://www.mikeperham.com/2010/04/03/introducing-phat-an-asynchronous-rails-app/ http://www.mikeperham.com/2010/01/27/scalable-ruby-processing-with-eventmachine/
- Broken Ruby's autoload http://redmine.ruby-lang.org/issues/show/921