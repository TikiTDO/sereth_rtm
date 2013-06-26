# Sereth Ruby Template Manager

UNDER DEVELOPMENT - DO NOT USE

**Requires Ruby 2.0**

Sereth RTM is a Ruby and CoffeeScript library developed to establish a common data representation and communication 
layer between a Ruby based server, and a JavaScript based web client.

The core goals of this project are to facilitate the export of fine-grained ruby objects into highly-dynamic
JavaScript templates, allow web clients to use these templates in order to render a web page, and to facilitate a mechanism for remote clients to track and update server based data when
for these web clients to keep this data syncronized with the server when authorized to do so.

**For Web Developers:** Please consult the usage guides for:
* [Ruby &harr; JS Interface](docs/usage.tunnel.md)
* [JS Templatesl](docs/usage.template.md)
* [Rails Integration](docs/usage.rails.md)

**For Ruby Developers:** Please consult the design notes for:
* [Ruby &harr; JS Interface](docs/design.tunnel.md)
* [JS Templates](docs/design.template.md)
* [Rails Integration](docs/design.rails.md)

## Installation

For the purpose of this example we will be using a new rails project. Skip the
generation step if using with an existing rails proejct.

```bash
 $ rails new rtm_demo
```

Add the json_rtm gem to the Gemfile.

```
Gemfile << gem 'rtm-json'
$ bundle install
```

Run rake task to generate the template structure
```
$ rake rtm:new
```

... TODO Install Guide ...

## Links
[Useful Links](docs/cool-links.md) | [Usecases](docs/usecases.md)

## TODO
Use async script loading for core elements

```javascript
function () {
  var scr = document.createElemetn('script'); scr.type = 'text/javascript';
  scr.async = true; src.src = 'http://blah';
  var s = documetn.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(src, s);
}
```

Remote spec type - Format

Include tattletale for console debugging

GitHub Integrator?

Stream results directly. Prolly not, seems slower unless rails4 improves it