# Using Rake with Plezi

When adding rake tasks to your application, you might find that the Plezi server automatically starts, distrupting Rake's flow.

To use Plezi with rake, make sure to require Plezi's rake support using

```ruby
require 'plezi/rake'
```

Plezi's rake support prevents the Iodine server (the server that Plezi uses) from running. Iodine's asynchronous task API will still remain active, so that any tasks scheduled to be performed will still run ay the end of the script.

The line that prevents the server from running is the following line thet Plezi uses internally:

```ruby
Iodine.protocol = false
```

## Rake based systems

Some systems use Rake, either internally or explicitly, to run common tasks such as deployment, testing, etc'.

For instance, [Capistrano](http://capistranorb.com) extends the Rake DSL to help with remote server automation and deployment.

This means that we should add the `require 'plezi/rake'` also within Capistrano's files (i.e. in the `config/deploy.rb` file).

Alternatively, we can use `Iodine.protocol = false` directly for any specific tasks.

## With Rails

Rails uses it's own script for opening a console and running certain tasks.

As JokerCatz (GitHub) suggested in a discussion related to Plezi, the following code can help Rails behave nicely when using Rake or the console. Add the following code to the `config/application.rb` file:

```ruby
if Rails.const_defined?('API') || Rails.const_defined?('Console')
    Iodine.protocol = nil
elsif Rails.const_defined?('Server')
    # # require the plezi application... if not already included.
    # require_relative  '../app/path/to/plezi/app.rb'
end
```
