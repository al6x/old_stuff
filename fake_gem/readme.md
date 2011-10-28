FakeGem - very handy hack that makes any directory looks like gem and greatly simplifies gem development. Forget about compiling & pushing Your gems or changing the Bundler's Gemfile file.
Yes, there's the :path opion in Bundler, but it doesn't solve the problem - if You have multiple projects depending on multiple gems - then You have to change multiple paths in multiple Gemfiles, that's boing. And the FakeGem solves this problem very easily.

## Usage

``` bash
fake_gem ~/my_projects
```

Let's suppose Your projects are located in the /my_projects dir, and because You respect the 'divide and rule' principle Your app divided into 3 modules - the app itself and 2 gems:

```
~/my_projects
  /app
  /lib1
  /lib2
```

You want lib1 and lib2 to be available as a gems while You are developing Your app, do following steps:

1 mark lib1 as fake_gem: create /projects/lib/fake_gem file and add there following lines:

    name: lib1
    libs: lib

2 do the same for lib2

3 enable fake_gem in current bash session, type:

    $ fake_gem ~/projects

All done, now lib1 and lib2 will be availiable as real gems in ruby scripts.
No changes needed to source code, You can use real gems or fake gems - the application knows nothing about it.

## Installation

```
gem install fake_gem
```