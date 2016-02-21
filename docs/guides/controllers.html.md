# Plezi&#39;s Controllers

In the core of Plezi's framework is a smart Object Oriented Router which acts like a "virtual folder" with RESTful routing and Websocket support.

RESTful routing and Websocket callback support both allow us to use conventionally named methods in our Controller to achive common tasks. Such names methods, as will be explored further on, include the `update`, `save` and `show` RESTful method names, as well as the `on_open`, `on_message(data)` and `on_close` Websocket callbacks.

The first layer of this powerful routing system is [the Plezi's Http Router and the core method `Plezi.route`](./routes).

The second layer of this powerful routing system is the Controller class which we are about explore.

## What is a Controller Class?

Plezi has the ability to take in any class as a controller class and route Http requests to the classes public methods. This powerful routing system has built-in support for RESTful methods (`index`, `show`, `new`, `save`, `update`, `delete`, `before` and `after`) and for WebSockets (`pre_connect`, `on_open`, `on_message(data)`, `on_close`, `broadcast`, `unicast`, `multicast`, `on_broadcast(data)`, `register_as(identity)`, `notify`).

In effect, Controller classes act as "virtual folders" where methods are the "files" served by the Plezi router.

To use a class as a Controller, simply attach it to a [route](./routes). i.e., type the following in your `irb` terminal:

    require 'plezi'
    class UsersController
        def index
            "All Users"
        end
        def show
	        "I would love to show you #{params['id']}... later."
        end
        def foo
	        "bar"
        end
    end
    Plezi.route "/users", UsersController
    exit # on `irb` we start Plezi by exiting `irb`

Notice the difference between [localhost:3000/users/foo](http://localhost:3000/users/foo) and [localhost:3000/users/bar](http://localhost:3000/users/bar).

\* you can read the demo code for [Plezi::StubRESTCtrl and Plezi::StubWSCtrl](https://github.com/boazsegev/plezi/blob/master/lib/plezi/handlers/stubs.rb) to learn more. Also, feel free to read more about the [Iodine Websocket and Http server](https://github.com/boazsegev/iodine) which powers Plezi's core. You can find helpful information about the amazing [Request](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Request) and [Response](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Response) objects.

## RESTful methods

Plezi contains special support for CRUD operations (Create, Read, Update, Delete) and RESTful requests through the use of the `:id` parameter (`params['id']`) and the following reserverd method names: `index`, `new`, `save`, `show`, `update`, `delete`, `before` and `after`.

By reviewing the Http request type (GET, POST, DELETE) the `:id` parameter (absent? `new`?) and the optional `:_method` parameters, Plezi will route RESTful requests to the correct CRUD method:


* `index` will be called when the request is GET and the `:id` parameter is missing.

    This method is often used to display a list (full or partial) of existing objects.

* `new` will be called when the `:id` parameter is set to `'new'` and the request type is GET (unless the `:_method` parameter emulates `DELETE`).

    This method is often used to display a form that allows the creation of a new object.

* `show` will be called when the request is GET and the `:id` parameter is present and isn't `new`.

    This method is often used to display a list (full or partial) of existing objects.

    There is no specific method used to display the `edit` form (which is often the same as the `new` form). It is recommended to use `show` for both tasks.

    Using `show` for "inline editing" and a better user experience is the recommeneded approach.

    Using `show` with an added query parameter i.e.: `?_method=edit` is also recommended when displaying the whole of the object's data form (same form used for the `new` method).

    A third approach is to seperate the "Display"/Public controller from the "Edit"/Admin controller using authentication and the `before` callback method (see more details later on). This approach allows us to display a totally different `index` and `show` result when the user is authenticated.

* `save` will be called when the `:id` parameter is missing, or is set to `'new'` and the request type is POST.

    This method is often used to post a form with the content of a new object. Once the object is created, the same view as the `:show` method will often be displayed. If there were errors while trying to create the object (saving had failed), it is common to redisplay the `new` form with any error data.

* `update` will be called when the `:id` parameter is set and the request type is POST (unless the `:_method` parameter emulates `DELETE`).

    This method is often used to update (save) data in an existing object.

* `delete` will be called when the `:id` parameter is set and the request type is DELETE **or** the `:_method` parameter emulates a `DELETE` request.

    To emulate a DELETE Http request, set the `:_method` parameter to `delete`, so that `params[:_method] == 'delete'`.

    To so so, use the `url_for` helper method or simply add the following to the URL query string `?_method=delete`.

* `before` (if exists) will be called before ANY request handled by the controller.

    It's recommended to use the `requested_method` when requiring authentication exemptions for specific methods (i.e `:index` and `:show`).

    If this method returns false (not nil), the request body is cleared, the controller exists and routes continue searching for the next applicable route (allowing the seperation of Editing/Admin Controllers from Viewing/Public Controllers).

* `after` (if exists) will be called after ANY request handled by the controller. Behaves the same as `before`, allowing cancellation of the response after the data had been processed.

### A sample CRUD Controller

Here's a sample Controller for CRUD RESTful requests:

```
class CRUDCtrl

    # every request that routes to this controller will create a new instance
    def initialize
    end

    # called when request is GET and params['id'] isn't defined
    def index
        "Listing all objects..."
    end

    # called when request is GET and params['id'] exists
    def show
        "nothing to show for id - #{params['id']} - with parameters: #{params.to_s}"
    end

    # called when request is GET and params['id'] == "new" (used for the "create new object" form).
    def new
        "Should we make something new?"
    end

    # called when request is POST or PUT and params['id'] isn't defined or params['id'] == "new"
    def save
        "save called - creating a new object."
    end

    # called when request is POST or PUT and params['id'] exists and isn't "new"
    def update
        "update called - updating #{params['id']}"
    end

    # called when request is DELETE (or params[:_method] == 'delete') and request.params['id'] exists
    def delete
        "delete called - deleting object #{params['id']}"
    end

    # called before request is called
    #
    # if method returns false (not nil), controller exists
    # and routes continue searching
    def before
        true
    end
    # called after request is completed
    #
    # if method returns false (not nil), the request body is cleared,
    # the controller exists and routes continue searching
    def after
        true
    end
end
# a simple RESTful path - all paths are assumed to be RESTful
route '/object', CRUDCtrl
# OR, to allow inline _method request parameter
route '/object/(:id)/(:_method)', CRUDCtrl
```

For using the `route` paths to add different request parameters, refer to the [routes guide](routes).

## The Controller as a virtual folder

As already demonstrated by the RESTful API design, the `:id` parameter is used to route the request to a specific CRUD method.

However, the `:id` parameter can also be used to GET or POST data to custom methods, so that a Controller can act as a "virtual API folder" or to group together a group of resources.

The perfect example is the "Root" path and it's related pages. i.e.:

    def RootCtrl
        def index
            "Welcome..."
        end
        def sitemap
            "/ - welcome page\n/sitemap - this page"
        end
        def echo
            request.to_s
        end
    end
    route '/', RootCtrl

This is a very powerful feature, especially when writing a backend with a Websocket API and an AJAJ (AJAX + JSON) fallback API (see the [JSON websocket Auto-Dispatch guide](json-autodispatch)).

(todo: complete documentation)

## Websocket Callbacks

Controllers can also be used for Websocket connections.

The same controller can answer Websocket connections as well as  CRUD, RESTful or AJAX (AJAJ when using JSON) requests.

This allows to easily write an API that serves both Websocket clients and AJAX/AJAJ cliects.

In order to answer Websocket connections, Plezi defines the following reserved callback methods: `pre_connect`, `on_open`, `on_message(data)`, `on_close` and `on_shutdown`.

To learn more about these callbacks and about Websockets, read the [websockets guide](websockets).

## Helper methods and objects

Once a controller class had been attached to a route, Plezi will inherit this class and add to it some functionality that is available within the controller's methods.

The following properties and methods are accessible from within your Controller classes.

### `request`

The request object is a Hash like object, containing the request's information and some helper methods.

Read more at the [YARD documentation for the Request object](http://www.rubydoc.info/gems/iodine/Iodine/Http/Request).

### `response`

The response object allows more control of the response, such as setting headers, streaming the response etc'.

Read more at the [YARD documentation for the Response object](http://www.rubydoc.info/gems/iodine/Iodine/Http/Response).

### The `params` hash

The `params` Hash includes all the data from form data, query data and route parameters that had been collected for the request.

It's a shortcut for `requst.params`.

Param keys are always symbols. Values are either Strings, numbers or `true`/`false`.

Uploaded files include the following data (assuming `:file_field` is the name of the file input in the Html form):

* `params[:file_field][:name]` - contains the original file's name.

* `params[:file_field][:type]` - contains the file's mime type.

* `params[:file_field][:size]` - contains the length of the file uploaded in bytes.

* `params[:file_field][:file]` - contains a Tempfile which stores the file data.

* `params[:file_field][:data]` - will dump the Tempfile data into the memory and store it in the Hash. Don't use this except if you intend to read the whole file data into the memory anyway.

Some param names are reserved, as they are used for common shortcuts or other uses. Reserved params names include:

* `:locale` - this param name will set the locale when using the I18n gem.

* `:format` - this param name will set the format of the template being rendered.

Read about [routes](./routes) to discover how to use the request path to set parameters.

### The `cookies` cookie-jar

The `cookies` cookie jar is a Hash that both reads and writes cookies (it uses `response.set_cookie` whenever a value is assigned to a cookie name).

To read a cookie name, simply:

    cookies[:name]

To set a cookie's value, simply:

    cookies[:name] = "value"

It's also possible to set the [`response.set_cookie` options](http://www.rubydoc.info/gems/iodine/Iodine/Http/Response#set_cookie-instance_method) when setting the value. i.e.:

    cookies[:name] = {value: "value", secure: true}

Remember, cookies are sent to the browser using Http headers - you CAN'T set cookies after the headers were sent. If streaming a response, make sure to set all cookies BEFORE streaming begins.

### The `flash` cookie-jar

The `flash` object is a little bit of a magic hash that sets and reads temporary cookies. These cookies will be removed after the next request sent by the client to the application.

Use it like a Hash, using `flash[:key]` to read or `flash[:key]=value` to set.

### The `session` storage

The session object is a LOCAL storage (unlike Rails which stors the data in a cookie) with a Hash like interface.

The session's lifetime is variable.

The client side identification should remain valid until the browser is restarted. BUT, the identification can still be used until the session's local storage had been cleared.

When using Redis, the local storage persists for up to 24 hours between connections.

When falling back on temp-file storage (no Redis), the local storage will persists until the server clears it's tmp folder. Usually, the tmp folder is cleared between restarts. It's possible to set the interval between tmp-folder cleanup to a different value (which is often the practice with web servers).

Be aware that Session hijacking is a serious threat and avoid trusting the session data before exposing private information on the web (i.e. require re-authentication before exposing private information).

The session object will be either Plezi's Redis session object (syncing local data when scaling) or the local [Tempfile session storage object that comes bundled with Iodine](http://www.rubydoc.info/gems/iodine/Iodine/Http/SessionManager/FileSessionStorage/SessionObject). They both share the same API.

### The `render` method

Renders a template file (.slim/.erb/.haml) to a String and attempts to set the response's 'content-type' header (if it's still empty).

For example, to render the file `body.html.slim` with the layout `main_layout.html.haml`:

    render :body, layout: :main_layout

or, for example, to render the file `message.json.slim`

    render :message, format: 'json'

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#render-instance_method).

### The `send_data` method (Http)

This method sends raw data to be saved as a file or viewed as an attachment. The browser behave as if it had recieved a file.

This is usful for sending 'attachments' (data to be downloaded) rather then a regular response.

This is also useful for offering a file name for the browser to “save as”.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#send_data-instance_method).

### The `requested_method` method

This method review's the request and returns the name of the controller method that was invoked.

This method can be useful within the `before` and `after` callbacks, allowing for authentication requirements or exemptions.

### The `redirect_to` method (Http)

This method does two things:

1. It sets redirection headers for the response.

2. It sets the `flash` object (short-time cookies) with all the values passed except the :status value.

i.e., to redirect within the same controller:

    redirect_to "https://www.google.com"

Unless `url` is a String, the controller will attempt to guess the URL using the `url_for` method. i.e., to redirect within the same controller, setting `flash[:notice]` to a message:

    redirect_to :index, notice: "my message"

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#redirect_to-instance_method).

### The `url_for` URL builder

The controller will attempt to guess the URL used to reach any path within it's parameters, setting query parameters if the parameters are not part of the route's path parameters. i.e.:

url_for :index # the root of the controller
url_for id: 1, \_method: :delete # the DELETE method emulation for RESTful ID 1.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#url_for-instance_method).

### The `full_url_for` URL builder

Same as `url_for`, but attempts to rebuild the full url (inluding the schema, port and domain name).
Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#full_url_for-instance_method).

### The `host_params` hash

This property allows access to the parameters Hash used to setup the host. There is little, if any, use for it, although it allows you to store host global data to be accessed by the controller (allowing the same controller to behave differently on different hosts).

## Websocket specific helpers

Some Controller helper methods are only relevant after a Websocket connection was established.

### Using `write` to write to a Websocket

After a websocket connection is established, it is possible to use `write` to write data to the websocket directly.

[`write`](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#write-instance_method) writes data to the websocket, framing the data as stated by the Websocket protocol.

`data` should be a String object.

If the String is Binary encoded, the data will be sent as binary data (according to the Websockets protocol), otherwise the data will be sent as a UTF8 string data.

Using `write` before a websocket connection was established will append the data to the Http response, leading to possible errors.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#write-instance_method).

### The `close` method (Websockets)

[`close`](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#close-instance_method) closes the websocket connection after sending the Websocket's appropriate frame.

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#close-instance_method).

### The `unicast` method (Websockets)

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#unicast-instance_method).

(todo: write documentation)

### The `broadcast` method (Websockets)

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#broadcast-instance_method).

(todo: write documentation)

### The `multicast` method (Websockets)

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#multicast-instance_method).

(todo: write documentation)

### The `register_as` Identity method (Websockets)

Registers the current connection under an unique Identity, creating a message queue that will expire after set lifetime (currently defaults to 7 days).

An Identity has a limited number of connections it can use. That number defaults to 1 (a single connection at a time), but can be expended to any number.

A single connection can register as a number of Identities, allowing varying lifetimes for different Identity message queues.

Example use:

    register_as "#{session.id}_daily", lifetime: 60*60*24, max_connections: 4
    register_as "#{session.id}_hourly", lifetime: 60*60, max_connections: 4


Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/InstanceMethods#register_as-instance_method).

**A note about the Identity API**:

It is true that the Identity API allows Identities with extremely large number of allowed connections to be used as broadcast "channels" for multiple "subscribers".

However, use of the Identity API where the same Identity has a large number of connections is NOT recommended for performance reasons.

Consider using an 'opt-out' system, leveraging the `broadcast` method, when you expect most of the websocket connections to listen for a certain event.

### The `notify` Identity method (Websockets)

Sends a message / notification to a specific Identity.

The message will wait in a message queue until the Identity is online or the Identity's message queue expires.

Use:

    notify "identity_value", :event_method, arg1, arg2, ...

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#notify-instance_method).

### The `registered?` Identity method (Websockets)

This method checks if a certain Identity is valid (is registered and it's lifetime had not expired).

Example use:

    registered? "identity_value"

Read more at the [YARD documentation for this method](http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#registered%3F-instance_method).

### The `placebo?` method (Websockets)

This method should return `false` unless this controller is a Placebo controller, as related to the Placebo API.

The Placebo API allows you to connect the Plize application to a remote, non-Plezi process using a Redis server. Use cases include connecting a Plezi application to a Plezi worker process or a Rails application that opted not to use Plezi directly.

In the (hopefuly close) future, a guide will be published about this API.
