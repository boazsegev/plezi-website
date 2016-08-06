# Plezi&#39;s Controllers

In the core of Plezi's framework is a smart Object Oriented Router which acts like a "virtual folder" with RESTful routing and Websocket support.

RESTful routing and Websocket callback support both allow us to use conventionally named methods in our Controller to achive common tasks. Such names methods, as will be explored further on, include the `update`, `create` and `show` RESTful method names, as well as the `on_open`, `on_message(data)` and `on_close` Websocket callbacks.

The first layer of this powerful routing system is [the Plezi's Http Router and the core method `Plezi.route`](./routes).

The second layer of this powerful routing system is the Controller class which we are about explore.

## What is a Controller Class?

Plezi has the ability to take in any class as a controller class and route HTTP requests to the classes public methods. This powerful routing system has built-in support for RESTful CRUD methods (`index`, `show`, `new`, `create`, `update`, `delete`) and for WebSockets (`pre_connect`, `on_open`, `on_message(data)`, `on_close`, `broadcast`, `unicast`, `multicast`).

In effect, Controller classes act as "virtual folders" where methods behave similarly to "files" and where new "files" can be created, edited and deleted by implementing the special (reserved) methods for these actions.

To use a class as a Controller, simply attach it to a [route](./routes). i.e., type the following in your `irb` terminal:

```ruby
require 'plezi'
class UsersController
    def index
        "All Users"
    end
    def show
      "I would love to show you #{params[:id]}... later."
    end
    def foo
      "bar"
    end
end
Plezi.route "/users", UsersController
exit # on `irb` we start Plezi by exiting `irb`
```
Notice the difference between [localhost:3000/users/foo](http://localhost:3000/users/foo) and [localhost:3000/users/bar](http://localhost:3000/users/bar).

## Create Read Update Delete - CRUD

Plezi contains special support for CRUD operations (Create, Read, Update, Delete) and RESTful requests through the use of the `:id` parameter (`params['id']`) and the following reserverd method names: `index`, `new`, `create`, `show`, `update` and `delete`.

By reviewing the HTTP request method (GET, POST, PATCH, DELETE) the `id` parameter (absent? `new`?) and the optional `_method` parameters, Plezi will route RESTful requests to the correct CRUD method:


* `index` will be called when the request method is GET and the `id` parameter is missing or is `index`.

    This method is often used to display a list (full or partial) of existing objects.

* `new` will be called when the `'id'` parameter is set to `'new'` and the request method is GET.

    This method is often used to display a form that allows the creation of a new object.

* `show` will be called when the request method is GET and the `'id'` parameter is present, isn't `new` and isn't an existing public method.

    This method is often used to display a list (full or partial) of existing objects.

    There is no specific method used to display the `edit` form (which is often the same as the `new` form). It is recommended to use `show` for both tasks.

* `create` will be called when the `'id'` parameter is missing, or is set to `'new'` and the request method is POST.

    This method is often used to post a form with the content of a new object. Once the object is created, the same view as the `:show` method will often be displayed (sometimes simply redirecting the request). If there were errors while trying to create the object (saving had failed), it is common to redisplay the filled `new` form with any error data.

* `update` will be called when the `'id'` parameter is set and the request method is POST.

    This method is often used to update (save) data in an existing object.

* `delete` will be called when the `'id'` parameter is set and the request method is DELETE.

When any of the HTTP methods aren't supported by the client (i.e., some browsers don't support the DELETE method), it's possible to use the `:_method` parameter to emulate any method. i.e. `/resource/id?:_method=delete`.

### A sample CRUD Controller

Here's a sample Controller for CRUD RESTful requests:

```ruby
require 'plezi'
class CRUDCtrl
  # every request that routes to this controller will create a new instance
  def initialize
  end

  # called when request is GET and params['id'] isn't defined
  def index
    'Listing all objects...'
  end

  # called when request is GET and params['id'] exists
  def show
    "nothing to show for id - #{params['id']} - with parameters: #{params}"
  end

  # called when request is GET and params['id'] == "new" (used for the "create new object" form).
  def new
    'Should we make something new?'
  end

  # called when request is POST or PUT and params['id'] isn't defined or params[:id] == "new"
  def create
    'save called - creating a new object.'
  end

  # called when request is POST or PUT and params['id'] exists and isn't "new"
  def update
    "update called - updating #{params['id']}"
  end

  # called when request is DELETE (or params['_method'] == 'delete') and request.params[:id] exists
  def delete
    "delete called - deleting object #{params['id']}"
  end
end
# a simple RESTful path - all paths are assumed to be RESTful
Plezi.route '/object', CRUDCtrl
# OR, to allow inline _method request parameter, such as POST, PUT, GET or DELETE
Plezi.route '/object/(:id)/(:_method)', CRUDCtrl
```

For using the `Plezi.route` paths to add different request parameters, refer to the [routes guide](routes).

## The Controller as a virtual folder

As already demonstrated by the RESTful API design, the `'id'` parameter is used to route the request to a specific CRUD method.

However, the `'id'` parameter can also be used to GET, POST or DELETE data using custom methods, so that a Controller can act as a "virtual API folder" or to group together a group of resources.

Here's and example root path that uses method names to publish . i.e.:

```ruby
require 'plezi'

class RootCtrl
    def index
        "Welcome..."
    end
    def sitemap
        "/ - welcome page\n/sitemap - this page\n/echo - you know"
    end
    def echo
        request.env.to_s
    end
    def _not_published
      "methods starting with an underscore aren't exposed"
    end
    def has _arguments
      "methods with required arguments aren't exposed"
    end
    protected
    def secret
      "only un-inherited public methods are exposed."
    end
end
Plezi.route '/', RootCtrl
```

This is a very powerful feature, especially when writing a backend with a Websocket API and AJAJ (AJAX + JSON) fallback (see the [JSON websocket Auto-Dispatch guide](json-autodispatch)).

Run this example route and try visiting:

* [localhost:3000](http://localhost:3000)
* [localhost:3000/sitemap](http://localhost:3000/sitemap)
* [localhost:3000/echo](http://localhost:3000/echo)
* [localhost:3000/_not_published](http://localhost:3000/_not_published) - won't show.
* [localhost:3000/has](http://localhost:3000/has) - won't show.
* [localhost:3000/secret](http://localhost:3000/secret) - won't show.

## Websocket Callbacks

Controllers can also be used for Websocket connections, which makes it easier to reuse code when publishing an API that offers both HTTP and Websocket access.

In order to answer Websocket connections, Plezi (and Iodine) define the following reserved callback methods: `pre_connect`, `on_open`, `on_message(data)`, `on_close` and `on_shutdown`.

To learn more about these callbacks and about Websockets, read the [websockets guide](websockets).

## Helper methods and objects

Once a controller class had been attached to a route, Plezi will inherit this class and add to it some functionality that is available within the controller's methods.

The following properties and methods are accessible from within your Controller classes.

### `request`

The request object is a Rack::Request object, containing the request's information and some helper methods.

Read more at the [YARD documentation for the Request object](http://www.rubydoc.info/github/rack/rack/Rack/Request).

### `response`

The response object is a Rack::Response object and it more control over the response, such as setting headers, cookies etc'.

Read more at the [YARD documentation for the Response object](http://www.rubydoc.info/github/rack/rack/Rack/Response).

### The `params` hash

The `params` Hash includes all the data from Rack's `request.params` as well as any parameters provided within the route ([more on that in the routes guide](routes)).

Param keys are always strings (never symbols). Values are always Strings (except for `'_method'` which is a symbol).

Some param names are reserved for specific features, as they follow common practice. Reserved params names include:

* `'locale'` - this param name will set the locale when using the I18n gem.

* `'format'` - this param name will set the format of the template being rendered.

Read about [routes](routes) to discover how to use the request path to set parameters.

It's possible to use `@params = Plezi.rubyfy params` to rehash all the parameters so that all the data is html-sanitized (not SQL sanitized), the keys use Symbols instead of Strings and some strings are converted to their Ruby object couterpart (i.e. Fixnums, `true`, `false` and `nil` - empty strings are replaced with `nil`). However, this could break binary file uploads, so it isn't performed by default.

### The `cookies` cookie-jar

The `cookies` cookie jar is a Hash that both reads and writes cookies. It's a bit of syntetic sugar over Rack's `response.set_cookie`, `response.delete_cookie` and Rack's `request.cookies` hash access.

To read a cookie name, simply:

    cookies['name']

To set a cookie's value, simply:

    cookies['name'] = "value"

Since cookies are set using Rack's [`response.set_cookie` options](http://www.rubydoc.info/github/rack/rack/Rack%2FUtils.add_cookie_to_header), it's possible to set extra cookie properties when setting the value. i.e.:

    cookies[:name] = {value: "value", secure: true, httponly: true}

Remember, cookies are sent to the browser using HTTP headers - it is **not** possible to set cookies after the headers were sent. Make sure to set all cookies **before** aresponse is set - this is especially important to remember when implementing Websockets, remember to use the `pre_connect` callback for cookie setting.

### The `render` method

Renders a template file (i.e. `.slim`/`.erb`/`.md`) to a String and attempts to set the response's 'content-type' header (if it's still empty).

For example, to render the file `users/index.html.erb` with the layout `layout.html.slim`:

    render("layout") { render("users/index") }

Rr, for example, to render the same content in JSON format, using the templates `users/index.json.erb` with the layout `layout.json.erb`

    params['format'] = 'json'
    render("layout") { render("users/index") }

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#render-instance_method).

Rendering can be extended to include more render engines using the `Plezi::Renderer.register` method.

### The `requested_method` method

This method review's the request and returns the name of the controller method that was invoked.

### The `url_for` URL builder

The controller will attempt to guess the URL used to reach any path within it's parameters, setting query parameters if the parameters are not part of the route's fixed path parameters. i.e.:

```ruby
MyController.url_for :index # the root of the controller
MyController.url_for id: 1, \_method: :delete # the DELETE method can be emulated for RESTful requests.
```

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#url_for-instance_method).

## Websocket specific helpers

Some Controller helper methods are only available and relevant after a Websocket connection was established.

### Using `write` to write to a Websocket

After a websocket connection is established, it is possible to use `write` to write data to the websocket directly.

[`write`](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#write-instance_method) writes data to the websocket, framing the data as stated by the Websocket protocol.

`data` should be a String object.

If the String is Binary encoded, the data will be sent as binary data (according to the Websockets protocol), otherwise the data will be sent as a UTF8 string data. It's possible to use Plezi's `Plezi.try_utf8!` which will set a String's encoding to UTF-8 only when it's a valid encoding for that String.

Using `write` before a websocket connection was established will invoke undefined behavior and will probably leading nuclear missiles being directed at your home town.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#write-instance_method).

### The `close` method (Websockets)

[`close`](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#close-instance_method) closes the websocket connection after all the data was sent and sending the Websocket's appropriate goodbye frame.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#close-instance_method).

### The `unicast` method (Websockets)

Invokes a method for the specific websocket connection identified by it's id - use `self.id` to get the Plezi id for the websocket connection.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#unicast-instance_method).

(todo: write documentation)

### The `broadcast` method (Websockets)

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#broadcast-instance_method).

(todo: write documentation)

### The `multicast` method (Websockets)

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#multicast-instance_method).

(todo: write documentation)
