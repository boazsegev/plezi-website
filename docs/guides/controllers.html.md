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

\* you can read the demo code for Plezi::StubRESTCtrl and Plezi::StubWSCtrl to learn more. Also, feel free to read more about the [Iodine Websocket and Http server](https://github.com/boazsegev/iodine) which powers Plezi's core. You can find helpful information about the amazing [Request](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Request) and [Response](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/Http/Response) objects.

(todo: write documentation)

## RESTful methods

(todo: write documentation)

## Virtual folder

(todo: write documentation)

## Websocket Callbacks

(todo: write documentation)


