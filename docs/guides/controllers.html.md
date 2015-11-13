# Plezi Controllers

In the core of Plezi's framework is a smart Object Oriented Router which acts like a "virtual folder" with RESTful routing and Websocket support.

RESTful routing and Websocket callback support both allow us to use conventionally named methods in our Controller to achive common tasks. Such names methods, as will be explored further on, include the `update`, `save` and `show` RESTful method names, as well as the `on_open`, `on_message(data)` and `on_close` Websocket callbacks.

The first layer of this powerful routing system is [the Plezi's Http Router and the core method `Plezi.route`](./routes).

The second layer of this powerful routing system is the Controller class which we are about explore.

## What is a Controller Class?

Plezi has the ability to take in any class as a controller class and route Http requests to the classes public methods. This powerful routing system has built-in support for RESTful methods (`index`, `show`, `new`, `save`, `update`, `delete`, `before` and `after`) and for WebSockets (`pre_connect`, `on_open`, `on_message(data)`, `on_close`, `broadcast`, `unicast`, `multicast`, `on_broadcast(data)`, `register_as(identity)`, `notify`).

In effect, Controller classes act as "virtual folders" where methods are the "files" served by the Plezi router.

To use a class as a Controller, simply attach it to a [route](./routes). i.e.:

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

Notice the difference between [localhost:3000/users/foo](http://localhost:3000/users/foo) and [localhost:3000/users/bar](http://localhost:3000/users/bar).

\* you can read the demo code for [Plezi::StubRESTCtrl and Plezi::StubWSCtrl](https://github.com/boazsegev/plezi/blob/master/lib/plezi/handlers/stubs.rb) to learn more. Also, feel free to read more about the [Iodine Websocket and Http server](https://github.com/boazsegev/iodine) which powers Plezi's core. You can find helpful information about the amazing [Request](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Request) and [Response](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Response) objects.

(todo: write documentation)

## RESTful methods

(todo: write documentation)

## The Controller as a virtual folder

(todo: write documentation)

## Websocket Callbacks

(todo: write documentation)

## Helper methods and objects

(todo: write documentation)

### `request`

Read more at the <a href='http://www.rubydoc.info/gems/iodine/Iodine/Http/Request' target='_blank'>YARD documentation for the Request object</a>.

(todo: write documentation)

### `response`

Read more at the <a href='http://www.rubydoc.info/gems/iodine/Iodine/Http/Response' target='_blank'>YARD documentation for the Response object</a>.

(todo: write documentation)

### The `params` hash

(todo: write documentation)

### The `cookies` cookie-jar

(todo: write documentation)

### The `flash` cookie-jar

The `flash` object is a little bit of a magic hash that sets and reads temporary cookies. these cookies will live for one successful request to a Controller and will then be removed.

Use it like a Hash, using `flash[:key]` to read or `flash[:key]=value` to set.

### The `session` storage

The session object is a LOCAL storage (unlike Rails which stors the data in a cookie) with a Hash like interface.

The session's lifetime is variable.

The client side identification should remain valid until the browser is restarted. BUT, the identification can still be used until the session's local storage had been cleared.

When using Redis, the local storage persists for up to 24 hours between connections.

When falling back on temp-file storage (no Redis), the local storage will persists until the server clears it's tmp folder. Usually, the tmp folder is cleared between restarts. It's possible to set the interval between tmp-folder cleanup to a different value (which is often the practice with web servers).

Be aware that Session hijacking is a serious threat and avoid trusting the session data before exposing private information on the web (i.e. require re-authentication before exposing private information).

The session object will be either Plezi's Redis session object (syncing local data when scaling) or the local <a target='_blank' href='http://www.rubydoc.info/gems/iodine/Iodine/Http/SessionManager/FileSessionStorage/SessionObject'>Tempfile session storage object that comes bundled with Iodine</a>. They both share the same API.

(todo: write documentation)

### The `render` method

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#render-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `send_data` method (Http)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#send_data-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `requested_method` method

(todo: write documentation)

### The `redirect_to` method (Http)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#redirect_to-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `url_for` URL builder

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#url_for-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `full_url_for` URL builder

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/ControllerMagic/InstanceMethods#full_url_for-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `host_params` hash

(todo: write documentation)

### Using `write` to write to a Websocket

(todo: write documentation)

### The `unicast` method (Websockets)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#unicast-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `broadcast` method (Websockets)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#broadcast-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `multicast` method (Websockets)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#multicast-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `register_as` Identity method (Websockets)

(todo: write documentation)

### The `notify` Identity method (Websockets)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#notify-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `registered?` Identity method (Websockets)

Read more at the <a href='http://www.rubydoc.info/gems/plezi/Plezi/Base/WSObject/SuperClassMethods#registered%3F-instance_method' target='_blank'>YARD documentation for this method</a>.

(todo: write documentation)

### The `placebo?` method (Websockets)

(todo: write documentation)

