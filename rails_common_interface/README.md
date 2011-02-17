# Common Interface
Common Interface is a tool for **Rapid Web Interface Creation**, Ruby on Rails Plugin (more exactly, it's the concrete implementation of the [Abstract Inteface][abstract-interface] plugin).

Instead of trying to provide one universal user interface API (like GWT) to fit all needs, the [Abstract Interface][abstract-interface] **provides you with tools that ease creation of your own custom interface**.

Define Your design only one time, in one place, and then reuse it, forget about HTML and CSS in your Views.

It acts like an abstraction layer, allowing you to define your custom API (or DSL if you like) to build your user interface. Key point here - it allows you build such API **very quick and easy**.

# Demo

* [Sample of HomePage][sample1], [sample of page (with another design)][sample2]
* [List of all Samples][list_of_samples]

Real-life sample - [http://bos-tec.com](http://bos-tec.com), [http://bom4.com](http://bom4.com), there's no any custom template, all pages are made with the [Abstract Interface][abstract-interface] plugin.

# Advantages

* **Themes support** not only CSS, you can use completelly different HTML and layouts
* **DRY**
* **Clean views**
* **Iterative development**
* **Loose coupling of Logic and Design**
* **Share the same design with many Apps**
* **Mix two complete different themes** simultaneously, in the same page
* Start with simple prototype and when App matures create professional design (with minimum changes in App)
* Theme/Skin support (not only CSS but also Templates, Images, ...)
* Outsource design without opening App code
* Designers can go ahead and create working html/css/js
* Programmers can go ahead and create working App with simple design
* Both of them can do iterative prototyping that will be updated later

# Usage

1. sudo gem install rails-ext
2. install this plugin in your rails App
3. create symlink (in linux) or copy <plugin>/public/themes/ directory to <your_rails_App>/public
4. start your rails App and go to /theme


**Notice!** Common Interface is the interface that I build for my own need (you can also use it, by the way).
But to create you own design you need to create your own 'Common Interface', using this code as a sample.


Copyright (c) 2009 Alexey Petrushin [http://bos-tec.com](http://www.bos-tec.com), released under the MIT license.

[abstract-interface]: http://github.com/alexeypetrushin/rails-ext

[sample1]: http://bos-tec.com/theme_site/home?_layout_template=home&_theme=simple_organization
[sample2]: http://bos-tec.com/theme/page
[list_of_samples]: http://bos-tec.com/theme/index