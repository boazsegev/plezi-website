<!--<PageMap>
    <DataObject type="document">
        <Attribute name="title">A Ruby Websocket Chat with Plezi</Attribute>
        <Attribute name="author">Bo (Myst)</Attribute>
        <Attribute name="description">
            In this tutorial we explore how to quickly write a Ruby websocket chatroom applications using Plezi.
        </Attribute>
    </DataObject>
    <DataObject type="thumbnail">
        <Attribute name="src" value="http://localhost:3000/images/logo_thick_dark.png" />
        <Attribute name="width" value="656" />
        <Attribute name="height" value="256" />
    </DataObject>
</PageMap>-->
# The Chatroom Experience

A ["Hello World" tutorial](./hello_world) is wonderful, but Plezi really shines when it comes to Websockets.

In the landing page you have noticed a working demonstration for a fully working chatroom application, with a few lines of code executed through the `irb` terminal.

There's no point in showing the basics or repeating the code in the landing page.

If you're looking for some easy tutorial, this is **not** the place.

This tutorial aims at implementing complex concepts in a way that will allow us to implement real world websocket applications.

The chatroom application is just an excuse, a comfortable way to demonstrate more complex concepts.

## Getting Ready

Before we start coding, we'll start with a clean slate, a new Plezi application. Let's open our terminal window and type:

    $ plezi new hello_chat

We're going to rewrite the Controller (`app/my_controller.rb`) and html template (`views/welcome.html.erb`) quite heavily, so make sure you know where they are. If you're not sure, refer to the ["Hello World" tutorial](./hello_world).

I should probably note that the new application implements a simple, insecure (non-sanitized) chatroom. You can go ahead and have a look, I'll wait.

## JSON - The Common Practice

When implementing Websockets we often use JSON to communicate what type of message we're exchanging and it's details.

It's quite common for a message to look like this (I use epoch time stamps, but others may use String representation):

```json
{"event":"poke","from":"some_user","at":1470734881.272001}
```

Using JSON and the `'event'` property is such a common practice, it's practically a community standard. It's so common, I often think people forget it's not part of the raw Websocket protocol.

Plezi embraces this common practice, allowing us to leverage this design by implementing an (optional) "Auto Dispatch" feature.

This feature allows us to directly connect the `"event"` property with a controller's method name, so that websocket "events" invoke the corresponding method.

## JSON as a Websocket and AJAJ API unifier

As a side note, the (optional) Auto-Dispatch feature makes websocket functions behave in a similar way to HTTP functions, allowing for AJAJ (AJAX with JSON, or Asynchronous Javascript And JSON) requests to map directly to Websocket event handlers.

This API unification feature requires a few adjustments (such as a default value for the `event` argument, "rubyfying" the `params` hash and mapping the `params[:id]` to the `:event` property)... This tutorial will not get into these details.

However, you might notice some similarities as we write our code, such as some return value types being written to the websocket (similarly, in HTTP, some return value types are appended to the response).

## Designing the events

Agile development means we can implement small pieces very quickly and then take these pieces out and replace them with different (hopefully better) implementations or workflows.

Basically it means that we make our plans one module at a time (kinda like Object Oriented Programming, we have Object Oriented Development) - so mistakes aren't as expensive.

### The User's Chatroom Journey

I'm guessing, for now, that the chatroom will provide the user with an experience similar to this one:

- The user logs in.

- Everyone is notified about the login and welcomes the new user.

- messages are exchanged.

- The user logs out.

- Everyone is notified about the logout.

Later we might add private messages, but for now, this is the flow for the public chat.

From this we can derive the following events, which I named with a `chat` prefix (to prevent later collisions): `chat_login`, `chat_message`, `chat_logout`

Let's translate this to Code.

### Public Chat Server Events

Our server will need to manage the events we defined. I'll put it for now in a separate module, we might move the code somewhere else later on.

```ruby
module PublicChat

  def chat_login event
  end

  def chat_message event
  end

  def chat_logout event
  end

end
```

As you can see, the design is simple. The method names are the same as the event names and each method accept the one objet - the event - which corresponds to the JSON hash we received.

For now, will fill this in as if we had all the websocket functionality we wanted. We might have to reorganize some things later, but at least we'll know what we want each event to perform.

Lets save this code as `app/public_chat.rb`:

```ruby
module PublicChat
  def chat_login(event = nil)
    if event.nil?
      # we will broadcast a login event to everyone in the chatroom.
      broadcast :chat_login, event: 'chat_login',
                             name: params[:nickname],
                             user_id: id
      # we don't need to send anything, this is taken care of by the JavaScript.
      nil
    else
      # We will forward the event to the websocket.
      event
    end
  end
  def chat_message(event, from_broadcast = false)
    if from_broadcast
      # we will simply forward the event to the websocket.
      event
    else # this event was invoked by the websocket
      # enforce the senders nickname and id
      event[:name] = params[:nickname]
      event[:id] = id
      # sanitize the message
      event[:message] = ::ERB::Util.h event[:message]
      # we will broadcast the message to everyone
      broadcast :chat_message, event, true
      # the data was received from the websocket, and we have nothing to "say" back.
      nil
    end
  end
  def chat_logout(event = nil)
    if event.nil?
      # if no event was received, it's us that are leaving the chatroom.
      broadcast :chat_logout, event: 'chat_logout',
                              name: params[:nickname],
                              userid: id
    else
      # forward the event to the websocket.
      event
    end
  end
end
```

We made a few assumptions. We assumed that `params[:nickname]` exists and we assumed that whatever value we return will be sent back to the websocket.

We'll need to fix these up later.

**Security Tip**: You might have noticed I sanitized the data we got from the user. It's super important to **NEVER trust data we get from the big scary internet**... people (and machines) send the weirdest things.

### Client events

Our client application will also need to send and receive events.

To make our lives easy, Plezi supplies us with a [ready to use Auto-Dispatch client](./json-autodispatch).

The route to the client can be adjusted and set, as described in the [routes](./routes) guide. For our use case we will simply load the client script from it's static file location at [/javascripts/client.js](http://localhost:3000/javascripts/client.js).

We can set up the client side events like so:

```javascript
client = NaN;
function connect2chat(nickname) {
  // set the global client object. The default connection URL is the same as our Controller's URL.
  client = new PleziClient();
  // Set automatic reconnection. This is great when a laptop or mobile phone is closed.
  client.autoreconnect = true
  // handle connection state updates
  client.onopen = function(event) {
  };
  // handle connection state updates
  client.onclose = function(event) {
  };
  // handle the chat_message event
  client.chat_message = function(event) {
  };
  // handle the chat_login event
  client.chat_login = function(event) {
  };
  // handle the chat_logout event
  client.chat_logout = function(event) {
  };
  return client;
}
```

We will need some extra helper functions and we'll need to fill those placeholder functions with some content... so let's save the following Javascript to `public/javascripts/public_chat.js`

```javascript
// the client object
client = NaN;
// A helper function to print messages to a DIV called "output"
function print2output(text) {
    var o = document.getElementById("output");
    o.innerHTML = "<li>" + text + "</li>" + o.innerHTML
}
// A helper function to disable a text input called "input"
function disable_input() {
    document.getElementById("input").disabled = true;
}
// A helper function to enable a text input called "input"
function enable_input() {
    document.getElementById("input").disabled = false;
    document.getElementById("input").placeholder = "Message";
}
// A callback for when our connection is established.
function connected_callback(event) {
    enable_input();
    print2output("System: " + client.nickname + ", welcome to the chatroom.");
}
// creating the client object and connecting
function connect2chat(nickname) {
    // create a global client object. The default connection URL is the same as our Controller's URL.
    client = new PleziClient();
    // save the nickname
    client.nickname = nickname;
    // Set automatic reconnection. This is great when a laptop or mobile phone is closed.
    client.autoreconnect = true
        // handle connection state updates
    client.onopen = function(event) {
        client.was_closed = false;
        // when the connection opens, we will authenticate with our nickname.
        // This isn't really authenticating anything, but we can add security logic later.
        client.emit({
            event: "chat_auth",
            nickname: client.nickname
        }, connected_callback);
    };
    // handle connection state updates
    client.onclose = function(event) {
        if (client.was_closed) return;
        print2output("System: Connection Lost.");
        client.was_closed = true;
        disable_input();
    };
    // handle the chat_message event
    client.chat_message = function(event) {
        print2output(event.name + ": " + event.message)
    };
    // handle the chat_login event
    client.chat_login = function(event) {
        print2output("System: " + event.name + " logged into the chat.")
    };
    // handle the chat_logout event
    client.chat_logout = function(event) {
        print2output("System: " + event.name + " logged out of the chat.")
    };
    return client;
}
// This will be used to send the text in the `input` to the websocket.
function send_text() {
    // get the text
    var msg = document.getElementById("input").value;
    // clear the input field
    document.getElementById("input").value = '';
    // no client? the text is the nickname.
    if (!client) {
        // connect to the chat
        connect2chat(msg);
        // prevent default action (form submition)
        return false;
    }
    // there is a client, the text is a chat message.
    client.emit({
        event: "chat_message",
        message: msg
    }, function(e) {
        print2output("Me: " + e.message)
    });
    // prevent default action (avoid form submission)
    return false;
}
```

Again, we're making a few assumptions which are actually promises we will have to keep. We assume two objects, one called `output` and the other called `input`. We'll fix that when we get into out HTML.

Also, in the true spirit of Agile development, we discovered we need another event to handle the user's log in process, since we will want to authenticate the user before logging them into the chat. So we added the `chat_auth` event.

Ideally, the `chat_auth` event will contain a single-use token with a short life-span or maybe data for a different authentication technique. At the moment, we have no server-side persistent data storage to manage users nor tokens, so we'll let it slide.

### Connecting the Javascript to the Client HTML































### Server side JSON

First, we'll need our application to parse the JSON format, we'll close the connection if this fails, because this will mean we're not talking to an authorized client.

Next, we will check the message type and route it to a method that will handle it correctly. For this we will need to write a __protected__ method (so the Http router doesn't think it's a public route) to handle chat messages. We'll call it `handle_chat`.

We'll also need to rewrite our `print` method... and while we're at it, let's change it's name, `print` is so 80's.

Our new `on_message` callback , `handle_chat` method and `print` (renamed to `emit`) will look something like this:

    class ChatServer
        def on_message data
            begin
                msg = JSON.parse(data)
            rescue
                return close
            end
            case msg['event']
            when /chat/
                handle_chat msg
            else
                # nothing right now
                nil
            end
        end

        protected

        def handle_chat message
            self.class.broadcast :emit,
                event: 'chat',
                from: ::ERB::Util.html_escape(params[:id]),
                to: 'public',
                uuid: uuid,
                data: ::ERB::Util.html_escape(message['data'])
        end

        def emit data
            write data.to_json
        end
    end

You might have noticed I keep sanitizing the data I get from the user. We'll optimize this later, but it super important to **NEVER trust data you get from the big scary internet**... people (and machines) send the weirdest things.

Another thing you might have noticed is the `uuid` that sliped in there. It's a great way to recoginze the websocket's connection and will allow us, later on, to support unicasting (sending messages to one person instead of the whole chatroom).

We also need to update our `on_open` and `on_close` to use JSON... This might be a good time to introduce a new type of event... It could, if we want it to, look something like this:

    class ChatServer
        def on_open
            unless params[:id]
                emit event: 'err', data: "You need a nickname to join the chat!"
                return close
            end
            # lets sanitize the nickname here,
            # so we don't repeat this all the time...
            params[:id] = ::ERB::Util.html_escape(params[:id])
            # inform others
            broadcast :emit,
                    event: 'connection',
                    data: 'join'
                    from: params[:id],
                    uuid: uuid
            # welcome our client
            emit event: 'connection',
                data: 'welcome'
                from: params[:id],
                uuid: uuid
        end
        def on_close
            broadcast :emit,
                    event: 'connection',
                    data: 'leave'
                    from: params[:id],
                    uuid: uuid
        end
    end

Wow, we already added two new types of message - connection messages and error messages... we can decide what to do with them when we get to our client code.

But first, we need to update the `handle_chat` method, because we already sanitized the nickname in our `on_open` callback:

    class ChatServer

        protected

        def handle_chat message
            self.class.broadcast :emit,
                from: params[:id],
                to: 'public',
                uuid: uuid,
                event: 'chat',
                data: ::ERB::Util.html_escape(message['data'])
        end
    end

### Client side JSON

To use JSON with javascript we will need to use `JSON.parse(e.data)` in our `onmessage(e)` callback. Our new javascript callback will look something like this (but don't follow my lead, I'm a lazy javascripter, and it's probably better to seperate this to more functions):

    ws.onmessage = function(e) {
        var msg = JSON.parse(e.data);
        switch(msg.event){
            case 'chat':
                output(msg.from + ": " + msg.data)
                break;
            case 'connection':
                switch(msg.data) {
                    case 'join':
                        output(msg.from + " joined the chat :-)");
                        break;
                    case 'leave':
                        output(msg.from + " left the chat :-/");
                        break;
                    case 'welcome':
                        output("Welcome, " + msg.from + " :-)");
                        break;
                }
            case 'err':
                output("Error: " + msg.data)
                break;
        }
    }

As you can see, we are starting to develop what is known as a "Protocol" for our server-client communication.

This also shows you how many options we really face.

For instance, we can move the conncetion listings to a side elemnt. We can also tell Plezi to react to a 'join' message by telling the original connection who's already here. Than, we can use that data (remember the uuid?) to send private messages to one user and not the others... We can even start using Plezi's Identity API to send messages to users who went off-line these messages will wait for a while, so if the user reconnects, they'll see what private messages they missed.

## Leveraging Plezi&#39;s Auto-Dispatch

The JSON `on_message` and `onmessage` callbacks we used are essentially a dispatch system that routes websocket `events` to methods in our Controller or Javascript client.

This use-case is so common, that Plezi includes an easy to use Auto Dispatch feature both for our Controller and our Client.

This allows us to replace out general purpuse `on_message` callback with event related methods which will be automatically invoked whenever the client "emits" an event. (we have a single `chat` event, but it's a start).

Let's re-write our application to leverage this wonderful feature.

You can read more about about it in the [JSON websocket event Auto-Dispatch guide](json-autodispatch).

### The Auto-Dispatch Controller

This is about to be a pretty minor rewite, we're mostly getting rid of code that is used to route the websocket `chat` event to the `handle_chat` method (which we will simply rename).

Let's start with a clean and empty controller. We'll just do one thing for now - we'll set the `@auto_dispatch` class flag to `true`, so that the controller uses the Auto Dispatcher.

    class ChatServer
        @auto_dispatch = true
    end

What are we keeping? We're keeping the authentication we wrote., So lets put that back in... but there is something we should change first.

The Auto-Dispatch will route any JSON `event` to a public or protected method. This allows us to expose some of our API both as Websocket events (using the JSON `event` property) or as AJAJ (AJAX with JSON) requests (using the `params[:id]` to route the request to the Http method). The protected methods will only be available as websocket events.

But...

What about helper methods, such as our `emit` method? How do we keep them out of the Http and Websocket routing system? Easy, Plezi has us covered with the underscore (`_`) sign. Any method starting with an underscore will be inaccessible to both the Http router and the websocket auto-dispatcher.

Our `emit` helper method will now be called `_emit`.

Also, because we are using the auto-dispatcher, we can have plenty of both client-side and server-side events. So instead of the connection event being a single event with subtypes, we'll have different events for each type.

Our authentication logic will now look like this:

    class ChatServer
        @auto_dispatch = true
        def _emit data
            write data.to_json
        end
        def on_open
            unless params[:id]
                _emit event: 'err', data: "You need a nickname to join the chat!"
                return close
            end
            # lets sanitize the nickname here,
            # so we don't repeat this all the time...
            params[:id] = ::ERB::Util.html_escape(params[:id])
            # inform others
            broadcast :_emit,
                    event: 'joined',
                    from: params[:id],
                    uuid: uuid
            # welcome our client
            _emit event: 'welcome',
                from: params[:id],
                uuid: uuid
        end
        def on_close
            broadcast :_emit,
                    event: 'left',
                    from: params[:id],
                    uuid: uuid
        end
    end

Now it's time to add a handler for our `chat` event. Since the auto-dispatch will route every JSON `event` to a method with the same name, that's easy. We just need to write a method called `chat` that accepts a single parametere (the JSON data Hash).

    class ChatServer
        @auto_dispatch = true
        protected
        def chat msg
            self.class.broadcast :_emit,
                from: params[:id],
                to: 'public',
                uuid: uuid,
                event: 'chat',
                data: ::ERB::Util.html_escape(msg['data'])
        end
    end

Notice how we don't need an `on_message` callback or any complicated dispatching logic.

But... what happens when we get a message with a request we don't implement. Well, Plezi will automatically send an error response for unknown JSON requests and it will hang up the connection if the websocket message isn't valid JSON.

We can customize the error response by writing a callback called `unknown`. This will allow us to handle unknown JSON messages (Plezi will always disconnect when a non-JSON message is received). i.e.

    class ChatServer
        protected
        def unknown msg
            # by returning a string, it's automatically sent as a websocket message,
            # auto-dispatch methods behave the same as AJAX(AJAJ)/Http methods, so it's easy to unify
            # our code for both Websockets and AJAJ.
            {event: :err, status: 404, data: 'unknown request', request: msg}.to_json
        end
    end

Notice that unlike normal (raw) websocket methods (`on_open`, `on_close`, `on_message`), the auto-dispatch methods allow us to return a String (or a Hash) that will be written to the websocket automatically. This makes auto-dispatch methods act the same as Http methods, allowing us to write an API that is valid for both AJAJ and Websockets with a single method.

Here is the whole of our controller code:

    class ChatServer
        # Http
        def index
            render :client
        end
        # Websockets
        @auto_dispatch = true
        def _emit data
            write data.to_json
        end
        def on_open
            unless params[:id]
                _emit event: 'err', data: "You need a nickname to join the chat!"
                return close
            end
            # lets sanitize the nickname here,
            # so we don't repeat this all the time...
            params[:id] = ::ERB::Util.html_escape(params[:id])
            # inform others
            broadcast :_emit,
                    event: 'joined',
                    from: params[:id],
                    uuid: uuid
            # welcome our client
            _emit event: 'welcome',
                from: params[:id],
                uuid: uuid
        end
        def on_close
            broadcast :_emit,
                    event: 'left',
                    from: params[:id],
                    uuid: uuid
        end
        protected
        def chat msg
            self.class.broadcast :_emit,
                from: params[:id],
                to: 'public',
                uuid: uuid,
                event: 'chat',
                data: ::ERB::Util.html_escape(msg['data'])
        end
        def unknown msg
            # by returning a string, it's automatically sent as a websocket message,
            # auto-dispatch methods behave the same as AJAX(AJAJ)/Http methods, so it's easy to unify
            # our code for both Websockets and AJAJ.
            {event: :err, status: 404, data: 'unknown request', request: msg}.to_json
        end
    end

Next, we'll use a similar approach on our client-side Javascript.

### Serving the Auto-Dispatch Client

Plezi's Auto-Dispatch has a websocket javascript client that gets updated along with Plezi.

The client is also part of the application template and can be served as a static file / asset... but, this means that the client isn't updated when Plezi is updated.

To server the updated Plezi Auto-Dispatch javascript client we'll create a `:client` route, using the path of our choice. Add the following route at the end of the routes in our hello_chat application script:

    Plezi.route '/websocket/javascript/client.js', :client

Remember to restart the application whenever editing anything that isn't an asset of a template, such as the Ruby code (Controllers, Models, Routes, etc').

### The Auto-Dispatch PleziClient

Plezi provids a basic Websocket client that allows us to leverage the auto-dispatch "feel" and style also for our client side code.

To include the PleziClient from the route we just wrote, we will need to add the following line to out `head`

    <script src="/websocket/javascript/client.js"></script>

Next, we will want to create a client and define the handlers for the different client side events. For this we simply add callbacks to each of the event-names (the websocket events will start with the `on`). i.e., our client code will look something like this:

    client = new PleziClient(PleziClient.origin + "/" + $('#text')[0].value);
    client.onopen = function(e) {
        $('#text')[0].placeholder = 'your message';
    }
    client.onclose = function(e) {
        output("<b>Disonnected :-/</b>")
        $('#text')[0].placeholder = 'nickname';
        $('#text')[0].value = handle
    }
    client.chat = function(msg) {
        output(msg.from + ": " + msg.data);
    }
    client.joined = function(msg) {
        output(msg.from + " joined the chat :-)");
    }
    // ...

We can also use PleziClient's auto-reconnect feature

    client.reconnect = true
    client.reconnect_interval = 100 // interval between connections, in miliseconds

This will be the whole of our updated client:

    <!DOCTYPE html><html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
        <script src="/assets/plezi_client.js"></script>
        <script>
            client = NaN
            handle = ''
            function onsubmit(e) {
                e.preventDefault();
                var text = $('#text')[0].value
                if(text == '') {return false}
                if(client && client.connected) {
                    client.emit({event: 'chat', data: text});
                    $('#text')[0].value = '';
                } else {
                    handle = text
                    $('#text')[0].value = '';
                    client = new PleziClient(PleziClient.origin + "/" + text);
                    client.onopen = function(e) {
                        $('#text')[0].placeholder = 'your message';
                    }
                    client.onclose = function(e) {
                        output("<b>Disonnected :-/</b>")
                        $('#text')[0].placeholder = 'nickname';
                        $('#text')[0].value = handle
                    }
                    client.chat = function(msg) {
                        output(msg.from + ": " + msg.data);
                    }
                    client.joined = function(msg) {
                        output(msg.from + " joined the chat :-)");
                    }
                    client.left = function(msg) {
                        output(msg.from + " left the chat :-/");
                    }
                    client.welcome = function(msg) {
                        output("Welcome, " + msg.from + " :-)");
                    }
                    client.unknown = function(msg) {
                        console.log("unknown event:");
                        console.log(msg);
                    }
                }
                return false;
            }
            function output(data) {
                $('#output').append("<li>" + data + "</li>")
                $('#output').animate({ scrollTop:
                            $('#output')[0].scrollHeight }, "slow");
            }
        </script>
    </head><body>
        <p>A real-time Websocket Chat Room? Easy!</p>
        <form id='form'>
            <input type='text' id='text' name='text' placeholder='nickname'></input>
            <input type='submit' value='send'></input>
        </form>
        <script> $('#form')[0].onsubmit = onsubmit </script>
        <ul id='output'></ul>
    </body>

Isn't the code more readable and beautiful?

The auto-dispatch feature allows both our client's code and our server's code to be shorter, more beautiful, easier to maintain and easier to read.

[todo: add unicasting / identity support]
