# Sample Blog built with Rad and MongoDB

Online demo http://rad-sample.heroku.com (it's hosted using free Heroku instance and sometimes it takes about 10sec to start up, so please be patient).

Rad Framework: http://github.com/alexeypetrushin/rad_core

## Installation

Ruby, Ruby Gems and MongoDB must be installed (You can use free mongohq.com MongoDB cloud service).

Clone project, install dependencies, package CSS and JS assets (packaging needed for production only) and run it, below are detailed steps.

``` bash
cd ~/projects
git clone git://github.com/alexeypetrushin/rad_sample.git
cd rad_sample
gem install bundler
bundle install
rake assets:copy_to_public
thin start
```

Configure database: if You run MongoDB on Your local machine, there's no changes needed, it will use the 'blog_sample_development' database. To change this please update /runtime/config/models.yml file.

``` bash
$ rad
```

You'll see something like:

```
RAD 0.2.1 starting in :development mode (at 2011-07-29 20:22:36)
RAD http server started on localhost:4000
```

Go to [http://locahost:4000](http://locahost:4000)

## Specifications

```bash
rake spec
```

## IoC, Components and Configuration

This Sample uses two components: Models (lib/components/models.rb) and Blog (lib/components/blog.rb)

Components can be configured using configs, multiple configs actually. For example to configure the Blog Component You can use the following files: lib/components/blog.yml, runtime/config/blog.yml, runtime/config/production/blog.yml, they will be merged in the same order.

## Polymorphic routes (routes with Inheritance)

The Rad Framework support standard 'resource' routes (like Rails routes), but in this sample I use another routing scheme to demonstrate 'polymorphic' routes.
What does it means - 'polymorphic'? It means that the **routes can understand model and controller inheritance**, usually the 'resource' routes have following scheme:

```
app.com/posts/post_id
app.com/posts/post_id/update
app.com/comments/comment_id
app.com/comments/comment_id/update
```

with polymorphic routes the same will be:

```
app.com/post_id
app.com/post_id/update
app.com/comment_id
app.com/comment_id/update
```

polymorphic route is smart ennought to get missing type information from the model (router hits DB to get the model, but in fact there's **no extra DB call** because You anyway has to get this model in controller, and in this case You'll get this model from cache). This sample demonstrates usage of such routing scheme.
  
## Fast UI Prototyping

Check out the views in app/views, You don't see there any HTML/CSS stuff. By using fast UI prototyping framework http://github.com/alexeypetrushin/rad_common_interface we can save time and use clean views.
  
## Controller & View Inheritance

[TODO]

## Ajax

[TODO]