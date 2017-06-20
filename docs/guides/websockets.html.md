# Plezi Websockets

A lot of Plezi's features comes from the powerful [Iodine HTTP / Websocket Server](https://github.com/boazsegev/iodine) that supports it.

## What are Websockets? (skip if you know)

In a very broad sense, Websockets allow the browser communicate with the server in a bi-directional manner. This overcomes some of the limitations imposed by HTTP alone, allowing (for instance) to push real-time data, such as chat messages or stock quotes, directly to the browser.

In essence, while HTTP's workflow is a call and response (the browser "calls", the server "responds"), Websockets is a conversation, sometimes with long pauses, where both sides can speak whenever they feel the need to, sometimes simultaneously.

This, in nature, requires that both sides of the conversation establish a common language... this part is pretty much up to each application.

It's easy to think about it this way:

the browsers starts a call-response sequence. All websocket connections start as an HTTP call-response. The browser shouts over the internet "I want to start a conversation".

The server responds: "Sure thing, let's talk".

Than they start their websocket conversation, keeping the connection between them open. The server can also answer "no thanks", but than there's no websocket connection and the HTTP connection will probably die out.

### Establishing the connection (generic client)

The websocket connection is initiated by the browser using `Javascript`.

The `Javascript` should, in most applications, handle the following three Websocket `Javascript` events:

- `onopen`: a connection was established.
- `onmessage`: a message was received through the connection.
- `onclose`: an open connection had closed, or a connection initiated couldn't be established.

Here is a common enough example of a script designed to open a websocket:

    websocket = NaN

    function init_websocket()
    {
      //  no need to renew socket connection if it's open
      if(websocket && websocket.readyState == 1) return true;

      // initiate the url for the websocket... this is a bit of an overkill,
      // but it will allow you to copy & paste decent code
      var ws_uri = (window.location.protocol.match(/https/) ? 'wss' : 'ws') + '://' + window.document.location.host

      // initiate a new websocket connection
      websocket = new WebSocket(ws_uri);

      // define the onopen event callback
      websocket.onopen = function(e) {
          // what do you want to do now?
          // maybe send a message?
          websocket.send("Hello there!");
          // a common practice is to use JSON
          var msg = JSON.stringify({event: 'chat', data: 'Hello there!'})
          websocket.send(msg);
      };

      // define the onclose event callback
      websocket.onclose = function(e) {
        // you probably want to reopen the websocket if it closes
        setTimeout( init_websocket, 100 );
      };

      // define the onmessage event callback
      websocket.onmessage = function(e) {
        // what do you want to do now?
        console.log(e.data);
        // to use JSON, use:
        // msg = JSON.parse(e.data);
      };
    }

    init_websocket();

As you can tell from reading through the code, this means that the browser will open a new connection to the server, using the websocket protocol.

In our example the script sent a message: `"Hello there!"`. It's up to your code to decide what to do with the data it receives, be it using JSON or raw data.

When data comes in from the browser, the `onmessage` event is raised. It's up to your script to decipher the meaning of that message within the `onmessage` callback.

Now that we know a bit about what Websockets are and how to initiate a websocket connection to send and receive data... next up: How do we get Plezi to answer (or refuse) websocket requests?

## Communicating between the application and clients

A Plezi application can handle multiple websocket connection controllers, allowing us to use different connections for different tasks (such as file uploading on one connection while getting real-time updates on another).

To set up a route to accept websocket connections, our controller must **either** implement an `on_message(data)` callback **OR** be an `auto_dispatch` enabled controller (more about this powerful feature soon).

### Raw Websocket data communication

By default, Plezi allows us to use raw websocket data communication - which means that binary data (i.e. file upload data) as well as text data (i.e. JSON data) can be used.

To send raw data to the client using the websocket, use the method `write(data)`.

When using raw websocket communication, no data will be sent unless explicitly sent using `write(data)`.

If the data being sent is a UTF-8 encoded String, it will be sent as a text message. If it's a binary encoded String (like any Strings from Rack's HTTP `env`) the data will be sent in binary mode.

i.e., a websocket echo server using Plezi:

```ruby
class MyEcho
  def on_message data
    write data
  end
end

Plezi.route '/', MyEcho
```

To use the JSON format for websocket messages, we will need to parse and format the data using Ruby's `JSON.parse(data)` and `{my: :data}.to_json` as well as the Javascipt `JSON.parse(e.data)` and `JSON.stringify({my: "data"})`.

That's it. It really is all it takes to accept websocket connections and communicate with a websocket client using raw websockets.

There's a bit more in the [getting started guide](./basics) and I hope to finish writing a Websocket tutorial soon... However, I have noticed that the [Auto Dispatch feature](./json-autodispatch) is an easier way to accomplish mosts tasks.

Remember to set the javascript connection(s) path to the path of your websocket route(s).

#### Websocket Callbacks

When using Websockets, the following callbacks can be defined:

* `pre_connect` is called **before** the websocket connection is accepted. If the method returns `false`, the connection will be refused.

    Websocket connections start as an HTTP connections with an `upgrade` request. This callback is called before answering the HTTP request, while it's still possible to set Cookie data.

    This method is the recommended authentication "gateway" (authenticate before connecting), as websocket messages cannot be sent nor received at this point.

 * `on_open` is called **after** the websocket connection is accepted. It's also possible to use this method for belated authentication.

 * `on_message(data)` is called whenever the client sends data through the websocket. the `data` is the raw data, allowing for binary data as well as text/JSON data. `data` will be a String. It will be UTF-8 encoded for text data (including, but not only, JSON) and binary encoded when the data received was sent as a binary stream.

* `on_close` is called **after** the websocket connection was closed.

* `on_shutdown` is called **before** the websocket connection is closed, as part of the server's graceful shutdown process. This allows a special notification to be sent before closing the websocket connection.

    `on_close` will still be called after the connection was closed, assuming a graceful shutdown.

#### A sample Websocket Controller

The following is a sample Websocket controller, showcasing all the available callbacks as well as an Http `index` method (to show that Controllers can be used for both):

```ruby
require 'plezi'
class WebsocketSample
  # every request that routes to this controller will create a new instance
  def initialize
  end
  # Http methods are available
  def index
    "Hello World!"
  end
  # RESTful methods are available
  def show
    "showing object with id: #{params['id']}..."
  end
  # called before the protocol is swithed from HTTP to WebSockets.
  #
  # this allows setting headers, cookies and other data (such as authentication)
  # prior to opening a WebSocket.
  #
  # if the method returns false, the connection will be refused and the remaining routes will be attempted.
  def pre_connect
    true
  end
  # called immediately after a WebSocket connection has been established.
  # it blocks all the connection's actions until the `on_open` initialization is finished.
  def on_open
  end
  # called when new data is recieved
  #
  # data is a string that contains binary or UTF8 (message dependent) data.
  def on_message data
    puts "Websocket got: #{data}"
    write "echo: #{data}"
  end
  # called once, AFTER the connection was closed.
  def on_close
  end
  # called once, during **server shutdown**, BEFORE the connection is closed.
  # this will only be called for connections that are open while the server is shutting down.
  def on_shutdown
    write "Server shutting down. Goodbye."
  end
end
Plezi.route '/', WebsocketSample
```
### Websocket JSON Auto-Dispatch

It is very common for websocket applications to use json messages to "emit" JSON "events" and map these events to class methods or javascript callbacks.

This use-case is so common, that Plezi includes an easy to use Auto-Dispatch feature for the Controller and an Auto-Dispatch Javascript client (PleziClient).

When using the Auto-Dispatch, there is no need to write an `on_message` callback. However, the controller must set the class variable `@auto_dispatch` to `true`. i.e.:

    class JSONDemo
        # Sets this controller to accept JSON encoded websocket connections
        @auto_dispatch = true
        # then define events
        protected
        def event1 data
            #...
        end
        #...
    end

To learn more about the JSON websocket Auto-Dispatch read the [JSON Websocket Auto-Dispatch guide](json-autodispatch)

## Communicating between different Websocket clients

Plezi leverages Iodine's native Pub/Sub features as well as it's native Redis engine that allow Websocket clients to communicate across process and machine boundries.

The Pub/Sub idiom is very common with plenty of examples on the web. The examples in the [Hello Chatroom](/docs/hello_chat) guide should  offer a good starting point.

It should be noted that Iodine's Pub/Sub allows for connectionless Pub/Sub as well as the more common Websocket bound Pub/Sub (that dies along with the connection). This powerful feature is very versatile when used correctly... but is can also be performance draining when implemented poorly.

## Scaling Websocket Services

Plezi leverages Iodine's RedisEngine for easily scaling the Pub/Sub service across machine boundries.

This allows applications to run multiple servers that share their Pub/Sub event data.

To use Redis for scaling, simply tell Plezi the URL for the Redis server, by using the environment variable `PL_REDIS_URL` or `REDIS_URL`. i.e.:

    ENV['PL_REDIS_URL'] ||=  "redis://user:password@redis.example.com:9999"

It's also possible to manage load balancing and separation of interests by writing a number of different applications that all sync together using Redis, each application in charge of a different aspect of the whole design.

To use Redis scaling across multiple **different applications**, a shared Plezi channel should be set across all the applications. This is done by setting the `Plezi.app_name` to a unique (shared) name. i.e.:

    Plezi.app_name = 'chat_ffeda1b2c3d4'

By default, the `Plezi.app_name` is automatically set using the name of the application script. i.e., for an application script called `chat` (or `chat.rb`), the default channel will be: `"chat_app"`.

This is placeholder for future features and isn't in use at the moment.
