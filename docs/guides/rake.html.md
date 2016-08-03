# Using or Deploying Plezi with Rake

When adding rake tasks to your application, you might find that the Plezi automatically starts, distrupting Rake's flow. This could prevent tasks (including deplyment tests) from exiting after completion.

This autostart feature can be very comfortable when writing short mico-service script files and it allows us to focuse only on our application (rather then on a network layer). However, this feature is less comofrable when using Rake.

To use Plezi with rake, make sure to require Plezi's rake support in your `rakefile`:

```ruby
require 'plezi/rake'
```

Plezi's rake support disables the autostart feature and is equivalent to writing:

```ruby
require 'plezi'
Plezi.no_autostart
```

## Rake based systems

Some systems use Rake, either internally or explicitly, to run common tasks such as deployment, testing, etc'.

For instance, [Capistrano](http://capistranorb.com) extends the Rake DSL to help with remote server automation and deployment.

This means that we should add the `require 'plezi/rake'` also within Capistrano's files (i.e. in the `config/deploy.rb` file).

## With Rails

Rails uses it's own script for opening a console and running certain tasks.

As JokerCatz (GitHub) suggested in a discussion related to Plezi, the following code can help Rails behave nicely when using Rake or the console. Add the following code to the `config/application.rb` file:

```ruby
if Rails.const_defined?('API') || Rails.const_defined?('Console')
    Plezi.no_autostart
elsif Rails.const_defined?('Server')
    # # require the plezi application... if not already included.
    # require_relative  '../app/path/to/plezi/app.rb'
end
```
