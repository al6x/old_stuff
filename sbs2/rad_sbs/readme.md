Rad SBS (site, forum, e-commerce, organizer).

Documentation http://sbs.4ire.net

See it in action http://robotigra.ru http://ruby-lang.info http://petrush.in

# Installation

Note: if You using rvm it's convinient to install it in standalone gemset.

- ruby >= 1.9.2
- MongoDB running on the same machine on the default port (can be changed in config)

```
cd my_projects
git clone git://github.com/alexeypetrushin/rad_sbs.git
cd rad_sbs
gem install bundler
bundle install
rake initialize
rake import_sample_data
rad
```

Go to `http://localhost:4000` use `admin/admin` to log in.

Copyright (c) Alexey Petrushin http://petrush.in, released under the AGPL license.