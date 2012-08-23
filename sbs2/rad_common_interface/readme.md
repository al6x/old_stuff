# Common User Interface for the Rad framework

## Rad Face
[Rad Face][face] is a tool for **Rapid Web Interface Creation** for the Rad framework.

Instead of trying to provide one universal user interface API (like GWT) to fit all needs, the [Face][face] **provides you with tools that ease creation of Your own custom interface**.

Define Your design only one time, in one place, and then reuse it, forget about HTML and CSS in Your Views.

It acts like an abstraction layer, allowing you to define Your custom API (or DSL if you like) to build Your user interface. Key point here - it allows you build such API **very quick and easy**.

## Demo

* [Sample of HomePage][sample1], [sample of page (with another design)][sample2]
* [List of all Samples][list_of_samples]

Real-life sample - [http://robotigra.ru](http://robotigra.ru), [http://ruby-lang.info](http://ruby-lang.info), [http://petrush.in](http://petrush.in) there's no any custom template, all pages are made with the [Face][face] plugin.

## Advantages

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

## Usage

	$ sudo gem install common_interface

**Notice!** Default UI is the UI I build for my own need, it's not an universal solution (and maybe you can also use it).
But to create Your own design you need to create Your own 'Default UI', using this code as a sample.

## Development

### Less CSS
  
  $ lessc style.less > style.css
  $ lessc reset.less > reset.css

## License

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.

[face]: http://github.com/alexeypetrushin/rad_face

[sample1]: http://4ire.net/ci_sites/home?layout_template=home&theme=simple_organization
[sample2]: http://4ire.net/ci_elements/page?theme=default
[list_of_samples]: http://4ire.net/ci_demo