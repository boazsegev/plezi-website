# Plezi&#39;s JSON Websocket&#39;s Auto-Dispatch

It is very common for websocket applications to use json messages to "emit" JSON "events" and map these events to class methods or javascript callbacks.

This use-case is so common, that Plezi includes an easy to use Auto Dispatch feature both for the Controller and any Javascript client (usually a browser).

## Plezi&#39;s Auto-Dispatch Protocol Overview

The server-side Auto-Dispatch can be used with any client that uses JSON for websocket data, so it's easy to build native applications that use Plezi as a websocket backend.

The auto-dispatch defines and uses the following JSON "sub-protocol":

* All websockets much contain a "stringified" JSON dictionary (Hash) object as the root object. Plezi will close the connection if it receives a non JSON message on a path that uses Auto-Dispatch.

* The JSON object's property `'event'`, is routed to a method with the same name on the server (both on the Ruby server and the Javascript client).

    i.e. an event named `'auth'` will invoke the method `auth` and pass the method `auth` a single Hash parameter containing the JSON data.

    Ruby:

        @autodispatch = true
        def auth msg
            msg['event'] == 'auth'
        end
        # to use for both Websockets AND AJAX, make sure
        # the method is public and add a default value. i.e.
        def auth msg = nil
            if msg
              # is Websockets
              msg['event'] == 'auth'
            else
              # is AJAX
              params[:id] == 'auth'
              msg = params.dup
            end
            # this will write a JSON response for both
            # AJAX and Websockets
            {event: :connnection, token: "token"}.to_json
        end

    Javascript:

        client.auth = function(msg) {
            msg.event == 'auth'
        }

* JSON valid messages that do not contain an `'event'` property or that map to a non-existing method are routed to a callback named `unknown` (if it exists). By default (unless a the `unknown` callback exists), unknown events will be ignored by the client while the server will respond with a generic error message.

* JSON valid messages that contain the `_EID_` property (event ID), will be invoke an `_ack_` event upon receipt. The `_ack_` event's JSON data will contain only the `_EID_` sent. This is also used internally by Plezi's client API.

This sub-protocol allows to easily unify AJAX and Websocket APIs, when using the method's default argument value to indicated the request's source.

When using the Auto-Dispatch, there is no need to write an `on_message` callback. But the controller must set the class variable `@autodispatch` to `true`. i.e.

    class Demo
        @autodispatch = true
        #...
    end

## Serving the Auto-Dispatch client

Plezi's Auto-Dispatch has a websocket javascript client that gets updated along with Plezi.

The use of the javascript client is **optional**, but it does make writing the client side code somewhat easier when writing for a browser.

The client is part of the application template and can be served as a static file / asset... but, this means that the client isn't updated when Plezi is updated.

To server the updated Plezi Auto-Dispatch javascript client (the client version matching the active Plezi version), it's possible to create a `:client` route, using any available path:

    Plezi.route '/client.js', :client
    # or any other path
    Plezi.route 'a/very/unique/path/to/the/pl_client.js', :client

The client is also available when using the application template. The client's path is `/assets/plezi_client.js` for the mini application template and `/assets/javascript/plezi_client.js` for the larger, default application template.

### Leveraging the Plezi Client

Plezi provids a basic Websocket client that allows us to leverage the auto-dispatch "feel" and style also for our client side code.

#### Creating the client

To open a websocket connection to the current location (i.e, "https://example.com/path" => "wss://example.com/path"), use:

      var client = new PleziClient();

Notice that SSL preference will be preserved. This means that if we access the server using SSL, the websocket connection will also require SSL (using `wss`). If we access the server using an unencrypted connection, the websocket connection will NOT be encrypted (using `ws`).

To open a connection to a different path for the original server, use:

      var client = new PleziClient(PleziClient.origin + "/path");

i.e., to open a connection to the root ("/"), use:

      var client = new PleziClient(PleziClient.origin + "/");

To open a connection to a different URL or path, use:

      var client = new PleziClient("ws://full.url.com/path");

#### Event callbacks

To set up event handling, directly set an `<event name>` callback. i.e., for an event called `chat`:

      client.chat = function(event) { "..." }

#### `client.unknown(event)`

When unknown JSON messages arrive, it's possible to handle them using the `unknown` callback which will be called whenever there is no method that handles the event or an event is not specified in the JSON message. i.e.:

      client.unknown = function(event) { "..." }

#### `client.emit(event, callback, timeout)`

To emit an event in JSON format (send the JSON event to the Controller), use the `emit` method:

      client.emit({event: "chat", data: "the message"})

The emitted event will invoke the Controller's method on the server. When using an Auto-Dispatch Controller the event will invoke a method with the same name. When using a raw websocket controller, the event will be forwarded as a JSON String to the Controller's `on_message` callback.

It's possible to set a timeout and a local callback for the emitted event. The callback will only be called if the timeout was reached - no `_ack_` was received before the timeout (in miliseconds) specified.

Notice that this uses Plezi's Auto-Dispatch's protocol with regards to the event ID (the `_EID_` property will be overwritten) and the`_ack_` event to set a timeout once the event is sent (and cancel it when the `_ack_` is received).

      client.emit({event: "ping"},
        function(event, client){
          // notice that the client is accessible using the second argument
          console.log("The "+ event.event +" event timed out", event, client)
        },
        3000);

#### `client.emit_timeout=` &amp; `client.ontimeout(event)`

It's also possible to set a default timeout that will be used whenever a specific timeout wasn't specified

      client.emit_timeout = 3000;
      client.emit({event: "ping"},
        function(event, client){
          // notice that the client is accessible using the second argument
          console.log("The "+ event.event +" event timed out", event, client)
        });


It's also possible to set the client's `ontimeout` callback when using a single timout logic for some (or all) of the events.

      client.emit_timeout = 3000;
      client.ontimeout = function(event){
          // notice that `this` refers to the client
          console.log("The "+ event.event +" event timed out", event, this)
        };
      client.emit({event: "ping"});

#### Auto-reconnection

To automatically renew the connection when disconnections are reported by the browser, use:

      client.autoreconnect = true;
      client.reconnect_interval = 200; // sets how long to wait before reconnection attempts.

The automatic reconnection flag can be used when creating the client, using:

      var client = new PleziClient(PleziClient.origin + "/path", true);
      client.reconnect_interval = 100; // Or use the default 200 ms.

The default `reconnect_interval` value is 200 ms.

#### `client.reconnect()`

It's possible to manually reestablish a lost connection using:

      client.reconnect()

This will NOT close the existing connection (if still open), so that pending responses would be received... however, this could cause multiple open connections unless used with care.

#### `client.sendraw(data)`

To sent raw websocket data, use the `sendraw` method. This will cause disconnetions if Plezi's controller uses `@auto_dispatch` and the message isn't a valid JSON string. i.e. sending a raw string:

      client.sendraw("string")

#### `client.close()`

Manually closing the connection will prevent automatic reconnections:

      client.close()

## Writing an Auto-Dispatch Controller

To automatically map all incoming websocket JSON `event` messages to controller methods, use the `@auto_dispatch` flag.

Public methods will accept both AJAX and Websocket events. Protected methods will only be used for websocket JSON events.

Non JSON messages sent by the client will cause automatic disconnection.

Unknown events will be either answered with an `err` event or sent to the `unknown` callback, if defined.

Here's a quick JSON echo server:

    class MyEcho
      # enable auto_dispatch
      @auto_dispatch = true
      # define the unknown event callback
      # this will be used to echo everything JSON
      def unknown event = nil
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

## An Advanced Auto-Dispatch Example

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

* We use the `&lt;event name&gt;` callback for the javascript auto-dispatcher. This allows us to use the same code conventions for both our server and our client.

* We use the `unknown` callback (without the `on` perfix) to handle unknown JSON messages.

The example client code:

    var connection = new PleziClient();
    connection.onopen = function(e) {
      connection.emit(event: 'auth', token: "my_token");
      connection.emit(event: 'chat', message: "Hi everyone!");
      connection.emit(event: 'echo', data: "echo echo echo...");
      connection.emit(event: 'publish', title: 'Hmmm', content: "blah blah...");
    }
    connection.chat = function(e) {
      alert("Chat from: " e.from + "\n" + e.message)
    }
    connection.echo = function(e) {
      console.log(e);
    }
    connection.publish = function(e) {
      console.log(e);
    }
    connection.unknown = function(e) {
      console.log(e);
    }

## Reserved keywords

In addition to Ruby's reserevd keywords and class methods, such as `freeze` or `trust`, the following keywords are internal callbacks, methods and property names used by Plezi Controllers and they cannot be used as event names.

Using any of the reserved keywords as an event name - both the Ruby keywords and the Plezi keywords - will be treated the same as an unknown event and the method will NOT be invoked (instead, the `unknown` callback will be invoked).

* `on_open` - This is a reserved websocket callback name.

* `on_message` - This is a reserved websocket callback name.

* `on_close` - This is a reserved websocket callback name.

* `on_broadcast` - This is a reserved websocket callback name used internally to map broadcasted events to their respective method. It can also be used for non-Plezi websocket broadcasing when using Iodine's (the server's) API.

* `pre_connect` - This is a reserved websocket callback name.

* `on_message` - This is a reserved websocket callback name.

* `before` - This is a reserved callback name.

* `after` - This is a reserved callback name.

* `unknown` - This is a reserved auto-dispatch callback name.

* `unknown_event` - This is a reserved auto-dispatch callback name (for backwards compatibility).

* `uuid` - This is a reserved method name that returns the uuid for the current (websocket) connection.

* `unicast_id` - This is a reserved method name, same as `uuid`.

* `write` - This is a reserved websocket method name that writes data to the websocket.

* `close` - This is a reserved websocket/Http method name that closes the connection (disconnects the client).

* `unicast` - This is a reserved websocket method name used for sending messages to a specific websocket.

* `broadcast` - This is a reserved websocket method name used for sending messages to a specific websocket type of connection (type by Controller).

* `multicast` - This is a reserved websocket method name used for sending messages to all currently connected clients.

* `register_as` - This is a reserved websocket method name used for registering a specific connection under a specific Identity (Identity API).

* `notify` - This is a reserved websocket method name used for sending messages to a specific Identity (Identity API).

* `registered?` - This is a reserved websocket method name used for checking if a specific Identity is registered to accept messages (Identity API). This will return true for the Identity's lifetime (the message might not be read, but the "mailbox" exists).

* `request` - This is a reserved method/property name storing the Http request.

* `params` - This is a reserved method/property name storing the parameters (POSTed data or query parameters) of the Http request.

* `cookies` - This is a reserved method/property name storing (and setting) the Http cookies. Setting cookies can only be performed BEFORE the Http response's headers were sent (i.e. during `pre_connect` or any Http response method such as `index`).

* `session` - This is a reserved method/property name storing session data. Session data is stored either locally (on a tmp-file) or using Redis (if defined), so that session data CAN be stored even after the headers were sent (i.e. during websocket event handling).

* `response` - This is a reserved method/property name storing the Http response object. The Http response object can also be used to send websocket data (i.e. `response << "my data"`).

* `flash` - This is a reserved method/property name storing temporary (single use) cookies. The same rules regarding cookies apply to flash storage (set before headers are sent).

* `host_params` - This is a reserved method/property name storing the setting for the host (i.e., the path to the host's templates is used for the render engine).

* `redirect_to` - This is a reserved method name for Http redirection.

* `url_for` - This is a reserved method name for rebuilding (guessing) the first path to the controller, with the requested parameters as part of the URL (i.e. `url_for user.id` or `url_for id: :8, method: :_delete`). Re-write route parameters (i.e. `:locale` or `:format`) are preserved when rebuilding the URL.

* `full_url_for` - same as `url_for`, but prefixed with the current hostname (don't use if changing hosts).

* `send_data` - This is a reserved Http method name used for sending IO objects (Files) or data (usually binary) Strings. Emulates a static file sent, but attempts to avoid browser cashing.

* `render` - This is a reserved method name used for rendering templates for Http/AJAX (and even websocket/auto-dispatch) responses.

* `requested_method` - This is a reserved method name returning the Controller's method that was originally invoked by the Http request.

* `_route_path_to_methods_and_set_the_response_` - This is a reserved method name used internally after the Controller was initiallized, to process the request.

* `___review_identity` - This is a reserved websocket callback name used internally as part of the Identity API.

* `__get_io` - This is a reserved method name used internally for getting the IO protocol (Http / Websockets).

The following are reserved Ruby keywords that cannot be used as event/method names (this list might be partial):

`initialize`, `allocate`, `new`, `superclass`, `json_creatable?`, `freeze`, `===`, `==`, `<=>`, `<`, `<=`, `>`, `>=`, `to_s`, `inspect`, `included_modules`, `include?`, `name`, `ancestors`, `instance_methods`, `public_instance_methods`, `protected_instance_methods`, `private_instance_methods`, `constants`, `const_get`, `const_set`, `const_defined?`, `const_missing`, `class_variables`, `remove_class_variable`, `class_variable_get`, `class_variable_set`, `class_variable_defined?`, `public_constant`, `private_constant`, `singleton_class?`, `include`, `prepend`, `module_exec`, `class_exec`, `module_eval`, `class_eval`, `method_defined?`, `public_method_defined?`, `private_method_defined?`, `protected_method_defined?`, `public_class_method`, `private_class_method`, `autoload`, `autoload?`, `instance_method`, `public_instance_method`, `psych_yaml_as`, `yaml_as`, `psych_to_yaml`, `to_yaml`, `to_yaml_properties`, `to_json`, `nil?`, `=~`, `!~`, `eql?`, `hash`, `class`, `singleton_class`, `clone`, `dup`, `itself`, `taint`, `tainted?`, `untaint`, `untrust`, `untrusted?`, `trust`, `frozen?`, `methods`, `singleton_methods`, `protected_methods`, `private_methods`, `public_methods`, `instance_variables`, `instance_variable_get`, `instance_variable_set`, `instance_variable_defined?`, `remove_instance_variable`, `instance_of?`, `kind_of?`, `is_a?`, `tap`, `send`, `public_send`, `respond_to?`, `extend`, `display`, `method`, `public_method`, `singleton_method`, `define_singleton_method`, `object_id`, `to_enum`, `enum_for`, `equal?`, `!`, `!=`, `instance_eval`, `instance_exec`, `__send__`, `__id__`
