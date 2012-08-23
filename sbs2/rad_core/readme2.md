# Why make another Rails?

There are many things that I like in Rails:

- high productivity
- simplicity, agility and iterative development
- excellent and very usefull ruby extensions
- nice and very handy API and naming conventions
- no config and fast start with leaning learning curve

But, there are some problems:

- there's only one way - The Rails Way, it's all simple and cool when You are on this way. But if You wanna to step aside and do it in Your way - You'll get big problems, so big that they are almost completely eliminates all the goodness.
- very hard to extend and customize
- You forced to build monolithic applications, it's hard to build application as set of modules (partially fixed in Rails 3).
- weak support of object oriented paradigm, there's really no true inheritance in Controller and Routing scheme.
- hard to build distributed applications.

With Rad I tried to save all the goodness and use API as closed to Rails as possible but also give the developer freedom to choose it's own way and also solve those important problems.

# Finished functional

- Controllers (80% of Rails + new stuff)
- Views (80% of Rails + new stuff)
- Router (Polymorphic, Restful, Simple)
- Migrations (MongoDB, multiple databases, versions, up/down)
- Deployment automation (90% of capistrano + new stuff)
- Mailers (80% of Rails)
- Code reloading in :development
- Asset packaging
- MooTools support
- Specs support (Controllers, Models + new stuff)
- Console (nothing special, just like rails console)
- and more ...