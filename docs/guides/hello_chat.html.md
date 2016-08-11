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

This tutorial aims at implementing moderately advanced concepts, such as evented application design, in a way that will allow us to implement real world websocket applications.

The chatroom application is just an excuse, a comfortable way, to demonstrate more complex concepts.

## Getting Ready

To begin coding, start with a new Plezi application. Open our terminal window and type:

    $ plezi new hello_chat

If you haven't already familiarized yourself with the application files and structure, refer to the ["Hello World" tutorial](./hello_world) and at least locate the Controller (`app/my_controller.rb`) and html template (`views/welcome.html.erb`).

I should probably note that the new application implements a simple chatroom. You can go ahead and have a look, I'll wait.

## JSON - The Common Practice

When implementing Websockets we often use JSON to communicate what type of message we're exchanging and it's details.

It's quite common for a message to look like this (I use epoch time stamps, but others may use String representation):

```json
{"event":"poke","from":"some_user","at":1470734881.272001}
```

Using JSON and the `'event'` property is a very common practice, it's practically a community standard. Although it's so common, it's important to remember that it isn't part of the raw Websocket protocol and that sometimes other avenues will perform better (i.e. when sending binary data).

Plezi offers easy implementation for this common practice by implementing an (optional) "Auto Dispatch" feature.

This feature directly connects the `"event"` property with a controller's method name, so that websocket "events" invoke the corresponding method.

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

### Authenticating our Chatroom Session

It's time to implement our `chat_auth` event.

The following code in the Controller file (`app/my_controller.rb`) will handle our Chatroom authentication and provide the web application (the HTML and Javascript) to our client:

```ruby
# Replace this sample with real code.
class RootController
  # Set the controller to use Auto-Dispatch, mapping JSON events to methods.
  @auto_dispatch = true
  # HTTP
  def index
    # the template should be placed in: views/welcome/html.erb
    render 'welcome'
  end
  # Websocket on_close callback
  def on_close
    chat_logout if is_a?(PublicChat)
  end
  # Chat authentication event handler
  def chat_auth(event)
    # make sure we don't so this more then once
    if !is_a?(PublicChat) && event[:nickname]
      # sanitize the nickname
      params[:nickname] = ::ERB::Util.h event[:nickname]
      # add the PublicChat functionality (only once)
      extend PublicChat
      # call the log in event (and return it's result)
      chat_login
    else
      # we are being abused, close the connection
      close
    end
  end
end
```

The code is similar to the `PublicChat` module except for the `extend` method.

Plezi has a security oriented design, meaning no inherited functions are exposed to either HTTP.

However, once a connection was established, it's possible to added Websocket event handlers using the connection's instance method `extend`.

The `extend` method can only be called once - multiple calls will raise an exception, as they indicate possible security flaws.

The `extend` method can only be called by an instance of the Controller. Extending the Controller class won't expose any of the inherited methods to either HTTP or Websocket requests.

### The Client

The client's javascript is all done, but an HTML presentation layer should be provided.

If you're not up speed with current web design, a quick refresher: HTML is what we show (i.e. a button, a text), CSS is how we show it (i.e. the text color, the button's size) and Javascript is the code that manages interactions and events (i.e. what happens when we press the button, how the text change when an event occurs).

The following HTML goes in the `views/welcome.html.erb` template:

```html
<!DOCTYPE html>
<html>
<title>The Chatroom Example</title>
<head>
  <script src="/javascripts/client.js"></script>
  <script src="/javascripts/public_chat.js"></script>
    <style>
    html, body {width:100%; height: 100%; background-color: #ddd; color: #111;}
    h3, form {text-align: center;}
    input {background-color: #fff; color: #111; padding: 0.3em;}
    </style>
</head><body>
  <h3>The Chatroom Example</h3>
    <form id='form' onsubmit='send_text(); return false;'>
        <input type='text' id='input' name='input' placeholder='nickname'></input>
        <input type='submit' value='send'></input>
    </form>
    <script> $('#form')[0].onsubmit = send_text </script>
    <ul id='output'></ul>
</body>
</html>
```

### A quick recap

The application is ready. Restart the application (if it isn't running, run it now) and visit [localhost:3000](http://localhost:3000).

This example application is over-designed. The same results can be accomplished in far less code.

However, this example is extendable and demonstrates security considerations, dynamic websocket API considerations (we can connect from different controllers to the same chatroom) and evented design.

Congratulations for making it this far.
