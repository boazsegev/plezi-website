# Using Plezi with our existing Rack application

Plezi can be used as middleware as well as an application, so it can play well with our existing Sinatra / Rails / Rack applications, adding websocket support to our existing code.

We just need to remember the [Iodine](https://github.com/boazsegev/iodine) is currently required for Websocket support, since it's the only server that currently supports Websocket Callback Objects using the `env['upgrade.websocket']` proposal.

## Plezi as Rack middleware

Here's an example Rack application that demonstrates how to use Plezi as Middleware within a normal Rack application.

This will be the code in our example `config.ru` file.

```ruby
require 'plezi'
# our Plezi application
class MyCtrl
  def index
    'Hello from Plezi!'
  end
end
# Our Plezi route
Plezi.route '/plezi/*', MyCtrl
# The Rack application
app = proc { |_env| [200, { 'Content-Length' => '11' }, ['Hello Rack!']] }
# Use Plezi as Middleware
use Plezi
# run our Rack application
run app
```

## Using Plezi with Rails

According to the [Rails On Rack Guide](http://guides.rubyonrails.org/rails_on_rack.html#configuring-middleware-stack), adding Plezi to the middleware stack used by Rails is performed by editing the `application.rb` file or the environment specific configuration at `environments/<environment>.rb` and adding:

  ```ruby
  config.middleware.use Plezi
  ```

Depending on our appllication's needs, we might consider `config.middleware.insert_before` or `config.middleware.insert_after` to exercise more control. For example, when using Devise, we might want Plezi to run after the authentication layer, using:

```ruby
config.middleware.insert_after Warden::Manager, Plezi
```

## Using Plezi with Sinatra

Accordig to [Sinatra's README](http://www.sinatrarb.com/intro#Rack%20Middleware), Sintra is closer to it's Rack roots then Rails, providing us with a top-level `use` function.

Adding Plezi to Sinatra might look similar to adding Plezi to Rack. i.e.:

```ruby
require 'sinatra'
require 'plezi'

# our Plezi application,
class MyCtrl
  def index
    'Hello from Plezi!'
  end
end
# Our Plezi route
Plezi.route '/plezi/*', MyCtrl

use Plezi

get '/hello' do
  'Hello World'
end
```

## A note about rewrite paths

Be aware that any rewrite paths defined by Plezi could cause data loss, since the path will be rewritten but the data extracted won't be available to other middleware or the final application.

## A note about multi-threading

Plezi is designed to serve multiple concurrent connections and perform concurrent tasks - this is especially important when supporting websockets.

To achive this cuncurrency, Plezi uses Iodine, which is a multi-threaded and (optionally) a multi-process server.

Hence, it's not only important that we take care to keep the application's code (and any gems the app is using) thread-safe, but it's often important that we take care to disable any middleware of features that prevent concurrency, such as the `Rack::Lock` middleware.

## A note about Rake

**As a last note**: It's very likely that your Rack/Sinatra/Rack application is using Rake for it's tasks. Once you're done adding Plezi to your application, remember to edit the `rakefile` as mentioned in out guide about [Plezi with Rake](rake).
