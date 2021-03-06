# Plezi&#39;s smart routing system

At the core of Plezi's framework is a smart Object Oriented Router which acts like a "virtual folder" with RESTful routing and Websocket support.

RESTful routing and Websocket callback support both allow us to use conventionally named methods in our Controller to achive common tasks. Such names methods, as will be explored further on, include the `update`, `save` and `show` RESTful method names, as well as the `on_open`, `on_message(data)` and `on_close` Websocket callbacks.

The first layer of this powerful routing system is the Plezi's HTTP Router and the core method `Plezi.route`.

## What is a Route? (I probably know this, skip ahead)

Routes are what connects different URLs to different parts of our code.

When we visit `www.example.com/users/index` we expect a different page than when we go to `www.example.com/users/1`. This is because we expect the first URL to provide a page with the list of users while we expect the second URL to show us a specific user's page or data.

in the example above, all the requests are made to the server at `www.example.com` and it is the server's inner workings - the server's inner router - that directs the `/users/index` to one part of our code and `/users/1` to another.

Like all web applications, Plezi also has an inner router which routes each request to the corresponding method or code.

Plezi's routing system was designed to build upon conventions used in other routing systems together with an intuitive approach that allows for agile application development.

\* Except for file handling and the asset pipeline - which are file-system dependent - routes are case-sensitive.

## Defining a Route

We define a route using Plezi's `Plezi.route` method.

This method accepts a String that should point to a route's "root".

The method also requires either a class that the route leads to. This class is called a Controller.

Here are a few examples for valid routes. You can run the following script in the `irb` terminal:

```ruby
require 'plezi'

class UsersController
  def index
    puts requested_method, params
    puts request.env
    'All Users'
  end
  def show
    "Looking for user #{params[:id]}"
  end
  def new
    "A new user creation form"
  end
  def create
    "Creating a new user #{params.to_s}"
  end
  def John
    "John is a special guy."
  end
  protected
  def unseen
    'unpublished'
  end
end

class Catch
  def index
    'Catch All'
  end
end

# the "/users" group can be extended. for now, it will answer: "/users", "/users/new", "/users/1" and a little more...
# this is because that's all that UsersController defines as public methods.
Plezi.route '/users', UsersController

# this route includes a catch-all at the end and will catch anything that starts with "/stuff/"
# But, this means this route will route any GET request to "index", ignoring the suffix
Plezi.route '/stuff/*', UsersController

# A catch-all can be placed in the root of a path.
Plezi.route('*', Catch)

# this route will never be seen,
# because the catch-all route answers any request before we gets here.
Plezi.route('/never-seen', UsersController)

exit
```

You might notice that the route is smart enough to choose the correct method according to the request's path. i.e., try any of the following:

* [/users](http://localhost:3000/users)
* [/users/Mitchel](http://localhost:3000/users/Mitchel)
* [/users/John](http://localhost:3000/users/John)
* [/users/new](http://localhost:3000/users/new)
* [/users?_method=post&name=Jenny](http://localhost:3000/users?_method=post&name=Jenny)

v.s

* [/stuff](http://localhost:3000/stuff)
* [/stuff/Mitchel](http://localhost:3000/stuff/Mitchel)
* [/stuff/John](http://localhost:3000/stuff/John)


As you may have noticed, the route's order of creation was important and established an order of precedence.

Order of precedence allows us to create a catch-all route, in fear that it might respond to an invalid request.

### A note about inheritance

It's somewhat obvious that we want to create a route when we call `Plezi.route "/", MyClass`.

It's also obvious that, in our example, `MyClass` should behave and act as a Controller for the route.

Plezi understands this simple fact and doesn't require that `MyClass` inherit explicitly from Plezi's Controller class.

Instead, Plezi automatically implements the implied inheritance by using Ruby's powerful meta-programming features and module mixins, allowing `MyClass` to inherit everything it needs from Plezi::Controller and Plezi::Controller::ClassMethods.

### The `:id` parameter

Each route can lead to a number of possible Controller methods (access points).

Plezi's router attempts to add an optional `:id` parameter at the end of the route, which makes it possible for the router to choose the correct method to call when an HTTP request comes in.

Of course, if a catch-all is specified, the `:id` parameter can't be isolated and the router will be more limited in it's ability to route to the correct method within a Controller.

For example, the following two routes are identical:

```ruby
require 'plezi'

class UsersController
    def index
        "All Users"
    end
    def show
      "looking for #{params['id']}"
    end
end

Plezi.route "/users", UsersController
Plezi.route "/users/(:id)", UsersController

exit
```

It's possible to add different optional parameters either before or after the (:id) parameter... but the (:id) parameter is special and it **will** effect the way the Controller reacts to the request - this is what allows the controller to react to RESTful requests (more information about this later on).

For example:

```ruby
require 'plezi'

class UsersController
    def index
        "All Users"
    end
    def show
        @params = Plezi.rubyfy params # sanitize data + use symbols instead of strings
        params[:name] ||= "unknown"
        "Your name is #{ params[:name] }... why are you looking for user id '#{ params[:id] }'?"
    end
end

Plezi.route "/users/(:id)/(:name)", UsersController

exit
```

* now visit [/users/1/John](http://localhost:3000/users/1/John)

As you noticed, providing an `:id` parameter invoked the RESTful method `show`. This is only one possible outcome. We will discuss this more [when we look at the Controller](./controllers.md) being used as a virtual folder and when we discuss RESTful routes and methods.

### More inline parameters

Inline parameters come in more flavors:

* Required parameters signified only by the `:` sign. i.e. `'/users/:name'`.
* Optional parameters, as seen before. i.e. `'/users/(:name)'`.

Using inline parameters, it's possible to achive greater flexability with the same route, allowing our code to be better organized. This is especially helpful when expecting data to be received using AJAX or when creating an accessible API for native apps to utilize.

* Required parameters can't be placed after optional ones.

### Re-Write Routes

Sometimes, we want some of our routes to share common optional (or required) parameters. This is where "Re-Write" routes come into play.

A common use-case, is for setting the locale or language for the response. It's also a good way toset the format for the response (json, xml, html etc') when using AJAX.

To create a re-write route, we set the "controller" to false.

For Example:

```ruby
require 'plezi'

class UsersController
    def index
        case params['locale']
        when 'sp'
            "Hola!"
        when 'fr'
            "Bonjour!"
        when 'ru'
          # "Здравствуйте!"
          "\u0417\u0434\u0440\u0430\u0432\u0441\u0442\u0432\u0443\u0439\u0442\u0435!"
        when 'jp'
            # "こんにちは!"
            "\u3053\u3093\u306B\u3061\u306F!"
        else
            "Hello!"
        end
    end
end

# this is the re-write route:
Plezi.route "/:locale", /^(en|sp|fr|ru|jp)$/

# this route inherits the `:locale`'s result
# try:
#   /fr/users
#   /ru/users
#   /en/users
#   /it/users # => isn't a valid locale
Plezi.route "/users", UsersController

exit
```

Try the code above and visit:

* [localhost:3000/users](http://localhost:3000/users)
* [localhost:3000/fr/users](http://localhost:3000/fr/users)
* [localhost:3000/ru/users](http://localhost:3000/ru/users)
* [localhost:3000/en/users](http://localhost:3000/en/users)
* [localhost:3000/it/users](http://localhost:3000/it/users) (doesn't exist, does it?)

Notice the re-write route contains an implied catch all. This catch-all is automatically added if missing. The catch-all is the part of the path that will remain for the following routes to check against.

### The Plezi Assets Route

By default, Plezi assumes assets are baked and served as static files.

However, during development, it's comfortable to have our assets served dynamically and updated live.

Also, sometimes we forget to bake some (or all) of the assets before deployment to a production environment (or we're just lazy).

Plezi has our back by providing us with the built in `:assets` controller.

Plezi will allow live updates to assets during development, but in production mode (using `ENV['RACK_ENV'] = 'production'`) Plezi will "bake" any missing assets to the public folder, so that the next request can be served by the static file server without getting the Ruby layer involved.

For example:

```ruby
Plezi.assets = 'my/assets' # defaults to 'assets'

Plezi.route "/assets", :assets
```

`Plezi.assets` defaults to the subfolder `'./assets'`, but this can be changed to suite your naming preferences.

`Plezi.route "/assets", :assets` will create the route for the `:assets` baking controller.

Using `:assets` as a controller allows us to control asset priority over other dynamic requests, but it also means Plezi does **not** provide any default asset management.

### The Plezi Client Route

Plezi's Auto-Dispatch has a websocket javascript client that gets updated along with Plezi.

The client is also part of the application template and can be served as a static file... but, this means that the client isn't updated when Plezi is updated.

To server the updated Plezi Auto-Dispatch javascript client (the client version matching the active Plezi version), Plezi offers the creation of a `:client` route, using any path of our choice:

```ruby
Plezi.route '/client.js', :client
# or any other path
Plezi.route 'a/very/unique/path/to/the/pl_client.js', :client
```
More information about the Auto-Dispatch controller and client can be found in the [websockets guides](./websockets).

However, consider updating the static file to the latest version, as static file serving is more performant.

## The next step

Now that we have learned more about the power of Plezi's routing system, it's time to [learn more about what Controller classes can do for us](./controllers).
