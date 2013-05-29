# Development Toolkit Design

Distribution: Ruby Gem

## Ruby
  Library Manager: Gem + Bundler
  Testing: RSpec

  Tool Support: Rails

  Sprocket engine for template generation

```ruby
# Parses the first javascript tag to extract stuff
coffee:
  initiate () ->
    ... # Run once when the template is loaded for the first time. Usually populates context
  around_render (args, render) ->
    ... # Run every time the template is rendered. Instantiates context. All args 
    return render(args) # Return the actual result of the render operation
    # The render operation generates HTML from the rest of the template
  before_render (args) ->
  after_render (dom) ->
```

## JS
  Library Manager: Bower?
  Testing: Jasmine Testing
