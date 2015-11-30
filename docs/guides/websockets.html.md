# Plezi Websockets

Inside Plezi's core code is the pure Ruby HTTP and Websocket Server (and client) that comes with [Iodine](https://github.com/boazsegev/iodine), a wonderful little server that supports an effective websocket functionality both as a server and as a client.

Plezi augmentes Iodine by adding auto-Redis support for scaling and automatically mapping each Contoller Class as a broadcast channel and each server instance to it's own unique channel - allowing unicasting to direct it's message at the target connection's server and optimizing resources.

Reading through this document, you should remember that Plezi's websocket connections are object oriented - they are instances of Controller classes that answer a specific url/path in the Plezi application. More than one type of connection (Controller instance) could exist in the same application.

## What are Websockets? (skip if you know)

In a very broad sense, Websockets allow the browser communicate with the server in a bi-directional manner. This overcomes some of the limitations imposed by Http alone, allowing (for instance) to push real-time data, such as chat messages or stock quotes, directly to the browser.

In essense, while Http's worflow is a call and response (the browser "calls", the server "responds"), Websockets is a conversation, sometimes with long pauses, where both sides can speak whenever they feel the need to.

This, in nature, requires that both sides of the conversation establish a common language... this part is pretty much up to each application.

It's easy to think about it this way:

the browsers starts a call-response sequence. All websocket connections start as Http call-response. The browser shouts over the internet "I want to start a conversation".

The server responds: "Sure thing, let's talk".

Than they start their websocket conversation, keeping the connection between them open. The server can also answer "no thanks", but than there's no websocket connection and the Http connection will probably die out (unless it's Http/2).

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

When data comes in from the browser, the `onmessage` event is raised. It's up to your script to decypher the meaning of that message within the `onmessage` callback.

Now that we know a bit about what Websockets are and how to initiate a websocket connection to send and receive data... next up, how to get Plezi to answer (or refuse) websocket requests?

## Communicating between the application and clients

A Plezi application can handle multiple websocket connection controllers, allowing you to use different connections for different tasks (such as file uploading on one connection while getting real-time updates on another).

For a route **to accept websocket connections**, it's controller **must** respond to the `on_message(data)` callback **OR** be an `auto_dispatch` enabled controller (more about this soon).

### Raw Websocket data communication

By default, Plezi allows us to use raw websocket data communication - which means that binary data (i.e. file upload data) as well as text data (i.e. JSON data) can be used.

To send raw data to the client using the websocket, use the method `write(data)`.

When using raw websocket communication, no data will be sent unless explicitly sent using `write(data)` or `request << data`.

If the data being sent is a UTF-8 encoded String, it will be sent as a text message. If it's a binary encoded String the data will be sent in binary mode.

i.e., a websocket echo server using Plezi:

    class MyEcho
      def on_message data
        write data
      end
    end

    route '/', MyEcho

To use the JSON format for websocket messages, you will need to parse and format the data using Ruby's `JSON.parse(data)` and `{my: :data}.to_json` as well as the Javascipt `JSON.parse(e.data)` and `JSON.stringify({my: "data"})`.

That's it. It really is all it takes to accept websocket connections and communicate with a websocket client using raw websockets.

You can see a more complete example, including the use of JSON, in the [Plezi chatroom tutorial](./hello_chat) as well as in the [getting started guide](./basics)

Remember to set the javascript connection(s) path to the path of your websocket route(s).

### Websocket JSON Auto-Dispatch

It is very common for websocket applications to use json messages to "emit" "events" and map these events to class methods or javascript callbacks.

This practice is also used to unify AJAX and Websocket APIs, when using the method's default argument value to indicated if the request was AJAX or Websocket in it's source.

Because this is so common, Plezi offers both a Client and a Controller automation flag that will automate the process, so that we doing have to write an `on_message` callback to route our events.

#### Leveraging the Plezi Client

Plezi provids a basic Websocket client that allows us to leverage the auto-dispatch "feel" and style also for our client side code.

The client is available when using the application template, using the path `/assets/plezi_client.js` (for the mini application starter) or `/assets/javascript/plezi_client.js` (for the larger, default application starter).

To open a websocket connection to the current location (i.e, "https://example.com/path" => "wss://example.com/path"), use:

      var client = new PleziClient();

Notice that SSL preference will be preserved. This means that if we access the server using SSL, the websocket connection will also require SSL (using `wss`). If we access the server using an unencrypted connection, the websocket connection will NOT be encrypted (using `ws`).

To open a connection to a different path for the original server, use:

      var client = new PleziClient(PleziClient.origin + "/path");

i.e., to open a connection to the root ("/"), use:

      var client = new PleziClient(PleziClient.origin + "/");

To open a connection to a different URL or path, use:

      var client = new PleziClient("ws://full.url.com/path");

To automatically renew the connection when disconnections are reported by the browser, use:

      client.reconnect = true;
      client.reconnect_interval = 250; // sets how long to wait before reconnection attempts.

The automatic renew flag can be used when creating the client, using:

      var client = new PleziClient(PleziClient.origin + "/path", true);
      client.reconnect_interval = 250; // Or use the default 50 ms.

The default `reconnect_interval` value is 50 ms.

To set up event handling, directly set an `on<event name>` callback. i.e., for an event called `chat`:

      client.onchat = function(event) { "..." };

When unknown JSON messages arrive, it's possible to handle them using the `unknown` callback which will be called whenever there is no method that handles the event or an event is not specified in the JSON message. i.e.:

      client.unknown = function(event) { "..." };

To send / emit an event in JSON format, use the `emit` method:

      client.emit({event: "chat", data: "the message"});

To sent raw websocket data, use the `send` method. This will cause disconnetions if Plezi's controller uses `@auto_dispatch` and the message isn't a valid JSON string. i.e. sending a raw string:

      client.send("string");

Manually closing the connection will prevent automatic reconnections:

      client.close();

#### Writing an Auto-Dispatch Controller

To automatically map all incoming websocket JSON `event` messages to controller methods, use the `@auto_dispatch` flag.

Public methods will accept both AJAX and Websocket events. Protected methods will only be used for websocket JSON events.

Non JSON messages sent by the client will cause automatic disconnection.

Unknown events will be either answered with an `err` event or sent to the `unknown_event` callback, if defined.

Here's a quick JSON echo server:

    class MyEcho
      # enable auto_dispatch
      @auto_dispatch = true
      # define the unknown event callback
      # this will be used to echo everything JSON
      def unknown_event event = nil
        unless event
          # this is an AJAX request
          event = {event: "err", status: 404, request: params.dup}
          event[:request][:event] = event[:request].delete :id
        end
        event.to_json
      end
    end
    route '/', MyEcho

Notice how a default value of `nil` allowed us to use the method also for AJAX requests (where the `:id` parameter replaces the `:event` parameter in JSON).

The resone for the default value is that AJAX requests will call the method without providing ANY arguments (just like all Http requests, there are no arguments, only the `params` Hash). On the other hand, the auto-dispatcher will call the method while passing the event Hash data as a single argument.

Also notice that the method returned a String and that String was automatically send to the websocket. This is very different than Raw websocket communication and it will only occure when using the auto-dispatch (i.e., it will not occure for broadcasting).

The reson for the different design was to allow, specifically, auto-dispatched events to behave the same as AJAX events, so thet the API could easily be unified, allowing also to easily use template rendering for the response.

#### An Advanced Auto-Dispatch Example

Here is a more complex example that you can't run in the terminal (it references a model code which you might not have handy), but it explores a few powerful concepts such as AJAX and Websocket API unity as well as websocket broadcasting using a recursive method call.

Here are a few things to notice about the example we're about to explore:

* Using recursion in the example above allows us to avoid exposing a method to the auto-dispatcher, keeping all the logic of the event in the same event-mathod.

     We are leveraging the fact that AJAX requests will call the method without providing ANY arguments and the auto-dispatcher will call the method while passing the event Hash data as a single argument. This means that only the broadcasting API allows us to set the second argument.

* Using the `protected` keyword, we disable AJAX access to the `chat` and `auth` events.

* We also limit access to AJAX methods by using the routing system.

* We have two routes for the same controller, allowing us to set different inline AJAX parameters (although the `:publish` event is probably expecting POST data rather than GET data).

* We can use `render`, exactly the same for both AJAX and Websocket messages. 

The example controller code:

    class MyAPI
      # enable auto_dispatch
      @auto_dispatch = true
      # define the publish event
      def publish event = nil, is_broadcast = false
        if is_broadcast
          # notice that we have to
          # explicitly send data when
          # using broadcasting
          return write(event.to_json)
        end
        unless event
          # this is an AJAX request
          auth()
          return false unless @user
          event = {event: 'publish',
            content: params[:content],
            title: params[:title]}
        end
        event[:author] = @user.id
        # now do the actual publishing
        # ...
        # next, broadcast the news to all
        # the websocket clients
        broadcast :publish, event, true
        event.to_json
      end
      def echo event = nil
        (event || params).to_json
        # # Or, even more interesting:
        # event ||= params
        # render :echo, format: 'json'
      end
      protected
      def auth event = nil
        is_ajax = event && true
        event = params unless event
        @user = User.where token: event[:token]
        close unless @user || is_ajax
      end

      def chat event, is_broadcast = true
        return write(event.to_json) if is_broadcast
        return ({event: :err,
          msg: 'authenticate first using the "auth" event',
          status: 400}.to_json) unless @user
        event[:from] = @user.name
        event[:from_id] = @user.id
        broadcast :chat, event, true
        render :chatmessage, format: 'ajax'
      end
    end
    route '/(:id){publish}/(:title)', MyAPI
    route '/(:id){echo}/(:message)/(:data)', MyAPI

We can use the PleziClient to communicate with our server.

As we read through the client, notice:

* We only `emit` events AFTER the connection was established (otherwise the `emit` will fail and return a `false` value).

* We use the `on&lt;event name&gt;` callback for the javascript auto-dispatcher. This uses Javascript conventions while the Ruby controller code is geared towards performance and Ruby conventions.

* We use the `unknown` callback (without the `on` perfix) to handle unknown JSON messages.

     The `on` is missing to allow both for writing an `unknown` event (which will invoke the `onunknown` javascript callback) and since the JSON message isn't an event - it's an unrecognized JSON message.

The example client code:

    var connection = new PleziClient();
    connection.onopen = function(e) {
      connection.emit(event: 'auth', token: "my_token");
      connection.emit(event: 'chat', message: "Hi everyone!");
      connection.emit(event: 'echo', data: "echo echo echo...");
      connection.emit(event: 'publish', title: 'Hmmm', content: "blah blah...");
    }
    connection.onchat = function(e) {
      alert("Chat from: " e.from + "\n" + e.message)
    }
    connection.onecho = function(e) {
      console.log(e);
    }
    connection.onpublish = function(e) {
      console.log(e);
    }
    connection.unknown = function(e) {
      console.log(e);
    }

## Communicating between different Websocket clients

Plezi supports three models of communication:

1. General communication - communicate between websocket connections.
2. Object Oriented communication - communicate between websocket connections of a specific Class/type (usualy the same route or "family" of routes).
3. Identity based communication - communicate between websockets based on the Identity of the connected client.

### General websocket communication

  When using this type of communication, it is expected that each connection's controller provide a protected instance method with a name matching the event name and that this method will accept, as arguments, the data sent with the event.

  This type of communication includes:

  - **Multicasting**:

      Use `multicast` to send an event to all the websocket connections currently connected to the application (including connections on other servers running the application, if Redis is used).

  - **Unicasting**:

      Use `unicast` to send an event to a specific websocket connection.

      This uses a unique UUID that contains both the target server's information and the unique connection identifier. This allows a message to be sent to any connected websocket across multiple application instances when using Redis, minimizing network activity and server load as much as effectively possible.

      When using `unicast`, it's also possible to define a `failed_unicast` Class callback that is unique to the Class of the object **sending** the unicast and accepts the following arguments `failed_unicast(target_id, event_name, args)` where `target_id` is the target's uuid, `event_name` is the websocket event name and `args` is a Array of the arguments send.

      Again, exacly like when using multicasting, any connection targeted by the message is expected to implemnt a method matching the name of the event, which will accept (as arguments) the data sent.

For instance, when using:

    unicast target_id, :event_name, "string", and: :hash

The receiving websocket controller is expected to have a protected method named `event_name` like so:

    class MyController
        #...
        protected
        def event_name str, options_hash
            #...
        end
    end

And the Sending controller can, optionally, have a class callback like so:

    class MyController
        #...
        def self.failed_unicast target, method, args
            #...
            # args == ["string", {:and => :hash}]
        end
    end

### Object Oriented communication

Use `broadcast` or `Controller.broadcast` to send an event to a all the websocket connections that are managed by a specific Controller class.

The controller is expected to provide a protected instance method with a name matching the event name and that this method will accept, as arguments, the data sent with the event.

The benifit of using this approach is knowing exacly what type of objects handle the message - all the websocket connections receiving the message will be members (instances) of the same class.

For instance, when using:

    MyController.broadcast :event_name, "string", and: :hash

The receiving websocket controller is expected to have a protected method named `event_name` like so:

    class MyController
        #...
        protected
        def event_name str, options_hash
            #...
        end
    end

### Identity oriented communication

Identity oriented communication should be used when Plezi's Redis features are enabled. To enable Plezi's automatic Redis features (such as websocket scaling automation, Redis Session Store, etc'), use:

    ENV['PL_REDIS_URL'] ||=  "redis://user:password@redis.example.com:9999"

Use `#register_as` or `#notify(identity, event_name, data)` to send make sure a certain Identity object (i.e. an app's User) receives notifications either in real-time (if connected) or the next time the identity connects to a websocket and identifies itself using `#register_as`.

Much like General Websocket Communication, the identity can call `#register_as` from different Controller classes and it is expected that each of these Controller classes implement the necessary methods.

It is a good enough practice that an Identity based websocket connection will utilize the `#on_open` callback to authenticate and register an identity. For example:

    class MyController
       #...
       def on_open
           user = authenticate_user
           close unless user
           register_as user.id
       end

       protected

       def event_name str, options_hash
           #...
       end
    end

It is recommended that the authentication and registration are split into two different events - the `pre_connect` for authentication and the `on_open` for registration - since, as a matter of security, it is better to prevent someone from entering (not establishing a websocket connection) than throwing them out (closing the connection within the `on_open` event).

Sending messages to the identity is similar to the other communication API methods. For example:

    notify user_id, :event_name, "string data", hash: :data, more_hash: :data

As expected, it could be that an Identity will never revisit the application or messages become outdated after a while. For this reason limits must be set as to how long any specific "mailbox" should remain alive in the database when it isn't acessed by the Identity. This is done within the `register_as` method i.e.:

    register_as user.id, lifetime: 1_814_400 # 21 days

Another consideration is that more than one "lifetime" setting might be required for different types of messages. The solution for this will be to allow a single connection to register as a number of different identities, each with it's own lifetime:

    # to register:
    register_as "#{user.id}-long", lifetime: 1_814_400 # 21 days
    register_as "#{user.id}-short", lifetime: 3_600 # 1 hour
    # to notify:
    notify "#{user.id}-long", :event_name #... 
    notify "#{user.id}-short", :event_name #... 

It should be noted that the lifetime is for the identity's lifetime and NOT the notification's lifetime. A notification sent a second before the identity "dies" will live for only a second and notify will return `true` all the same.

`notify` should return `true` or `false`, depending on whether the identity still exists.

It's also possible to `register_as` the same identity for more than one connection, it doing so is explicitly enabled. i.e.:

    def on_open
      # maximum of 5 concurrent connections
      register_as user.id, max_connections: 5
    end

