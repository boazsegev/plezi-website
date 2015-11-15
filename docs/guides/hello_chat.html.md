# A Plezi chatroom using Websockets

Just like the ["Hello World" tutorial](./hello_world) was used to explore some of what Plezi had to offer us in the world of Http and RESTful routing, this Chatroom tutorial can be used to explore some of what Plezi can do for us when it comes to websockets.

In the landing page you have noticed a working demonstration for a fully working chatroom application, with a few lines of code executed through the `irb` terminal.

First we will walk through the code and explore it to learn more about Websockets in Plezi, than we will see what we can tweek.

As I write this tutorial, I am hoping we will get to explore the different ways we can pass messages between the server and the clients, pushing real time data (chat messages, in this tutorial).

## The original code

The Plezi code from the landing page looked something like this:

    require 'plezi'
    class ChatServer
        def index
            render :client
        end
        def on_open
            return close unless params[:id]
            broadcast :print,
                    "\#{params[:id]} joind the chat."
            print "Welcome, \#{params[:id]}!"
        end
        def on_close
            broadcast :print,
                    "\#{params[:id]} left the chat."
        end
        def on_message data
            self.class.broadcast :print,
                        "\#{params[:id]}: \#{data}"
        end
        protected
        def print data
            write ::ERB::Util.html_escape(data)
        end
    end
    path_to_client = File.expand_path( File.dirname(__FILE__) )
    host templates: path_to_client
    route '/', ChatServer
    # finish with `exit` if running within `irb`
    exit

Now, let's start taking it apart...

### The outline

    require 'plezi'
    class ChatServer
        # ...
    end
    path_to_client = File.expand_path( File.dirname(__FILE__) )
    host templates: path_to_client
    route '/', ChatServer

This part of the code outlines the whole of the server.

`require 'plezi'` - We are using Plezi.

`class ChatServer #...` - We are creating a Controller class that will handle some tasks.

`host templates: path_to_client` - we are setting the `host` options for our server. More abot this in the [routes](/guide/routes) guide and the [./hello_world]("Hello World" tutorial).

Basically we are telling Plezi where we are keeping the html (or template) that we will be sending the browser. This Html will be our "client" application. 

Because websockets are like conversations, websocket applications require (at least) two sides, both "speaking" the same language. Usually there is a server and many clients. The server will be talking to all the clients, sometimes also delivering messages between clients.

The web page is the "client" for our web application. and the `path_to_client` tells Plezi where to look for the template.

`route '/', ChatServer` - We are connecting the `"/"` path to our `ChatServer` controller... 

... Actually, since Plezi is quite opinionated about it's routes, Plezi assumes we meant to write `"/(:id)"`, meaning that the optional `params[:id]` can be set using our route. i.e., our `ChatServer` will answer the request `"/my-name"` and will set the `params[:id]`'s value to be `"my-name"`.

Will take advantage of that to set data for the websocket connection later on.

### Sending our Client side application

As mentioned before, Websockets require both a server and a client. It's common for web applications to offer an Html+javascript client.

The following method answers the path `'/'` (the Controller's root or `index` path, no `:id`) by "rendering" our template into an Html file and sending it.

    class ChatServer
        def index
            render :client
        end
    end

`render` will automatically look up a file named `"client.html.erb"` in the `templates` folder we set up using `host`.

Actually, `render` will also look for `"client.html.slim"` and `"client.html.haml"` if we include these gems in our `Gemfile` (we can extend support also for more render engines).

### Listening to a connection

Once the browser got our client application and entered a nickname, it will try to connect to our server using Websockets. We want our application to listen to websocket connections.

Plezi makes this as easy as it gets. If our controller handles incoming Websocket data (using the `on_message(data)` callback), Plezi will automatically listen to incoming websocket connections on that route. i.e.,

    class ChatServer
        def on_message data
            # ... that's it, we answer websocket connections!
        end
    end


But, we don't WANT to accept any connection - we want to make sure that our user had a nickname (or authenticate them) first...

### Authenticating the connection

Plezi offers us two great ways to authenticate the connection:

* the `pre_connect` callback will prevent websocket connections from being established (a stay outside type of authentication).

    This approach is generally considered more secure, as no websocket connection was established quite yet. Plezi made sure the more common approach (using `on_open`) would be secure as well.

* the `on_open` callback will prevent any incoming websocket messages from being processed until it's finished. This allows us to use `on_open` for authentication without worrying about websocket messages being processed before we have completed our authentication.

    This is a "hallway" type of authentication (you can enter the hallway, but you're not all in just yet).

    The advantage of this approach is that it allows us to send back authentication error messages using our websocket connection as well as unify any initialization we need with the authentication.

In this example, our authentication process is simple, we just make sure our client has a nickname by using the `params[:id]` or we close the connection (remember Plezi's RESTful routing? no? we'll get back to it in a bit).

    class ChatServer
        def on_open
            return close unless params[:id]
            # ...
        end
    end

Since we use `on_open` (and not `pre_connect`), we can improve this by sending an error message on the websocket connection:

    class ChatServer
        def on_open
            unless params[:id]
                write "You need a nickname to join the chat!"
                return close
            end
            # ...
        end
    end

### Handling websocket data

After our client connects to our websocket controller, chat messages will start flowing. Also, we will want to let people know the client is here.

Enter `broadcast` on stage left...

The Controller's instance `broadcast` method will alert all it siblings (all the __other__ ChatServer websocket connections) to an event. We use it in our `on_open` callback to inform everyone about the new connection:

        def on_open
            return close unless params[:id]
            broadcast :print,
                    "\#{params[:id]} joind the chat."
            print "Welcome, \#{params[:id]}!"
        end

In this implementation, we broadcast an event called `:print`.

Events in Plezi are super simple, they are automatically routed to methods and any data attached to the event is automatically routed to the method's arguments.

We implement the `print` event by simply writing to the websocket (using the `write` method) after sanitizing the data and protectting ourselves from cross-site-scripting attacks (XSS):

    class ChatServer
        # notice the method must be protected,
        # so that it doesn't translate as an Http route.
        protected

        def print data
            write ::ERB::Util.html_escape(data)
        end
    end

That's it, it all makes sense now. Our `on_close` callback acts the same:

    class ChatServer
        def on_close
            broadcast :print,
                    "\#{params[:id]} left the chat."
        end
    end

And also out `on_message`... wait, no... our `on_message` callback uses a Class method instead of the instance method - this means that ALL of the ChatServer websockets receive the event - even our own instance:


    class ChatServer
        def on_message data
            self.class.broadcast :print,
                        "\#{params[:id]}: \#{data}"
        end
    end

It's just a convenience, we could have gotten a similar result (a bit lees asynchronous and a bit less DRY) using:

    class ChatServer
        def on_message data
            broadcast :print,
                    "\#{params[:id]}: \#{data}"
            print "\#{params[:id]}: \#{data}"
        end
    end

That's all we need from our server. Let's look at our client code.

### The client

This is not a Javascript or Html tutorial, so I will ignore styling in favor of functionality. I will also ignore some of the code and explain only what I think is most important or relevant.

If you clicked the "Client Code" button at the bottom of plezi.io's landing page, you probably saw the following peice of code:

    <!DOCTYPE html><html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
        <script>
            ws = NaN
            handle = ''
            function onsubmit(e) {
                e.preventDefault();
                if($('#text')[0].value == '') {return false}
                if(ws && ws.readyState == 1) {
                    ws.send($('#text')[0].value);
                    $('#text')[0].value = '';
                } else {
                    handle = $('#text')[0].value
                    var url = "ws://" + window.document.location.host +
                                '/' + $('#text')[0].value
                    ws = new WebSocket(url)
                    ws.onopen = function(e) {
                        output("<b>Connected :-)</b>");
                        $('#text')[0].value = '';
                        $('#text')[0].placeholder = 'your message';
                    }
                    ws.onclose = function(e) {
                        output("<b>Disonnected :-/</b>")
                        $('#text')[0].value = '';
                        $('#text')[0].placeholder = 'nickname';
                        $('#text')[0].value = handle
                    }
                    ws.onmessage = function(e) {
                        output(e.data);
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

The code is quite simple in concept (although I think the Javascript is a bit less readable and friendly when compared with Ruby).

There is a text input feild in a form. When the form is submitted, the application checks if a websocket connection is already established.

If there's no connection, the text in the input field is used as a nickname to establish a new connection. If a connection already exists, the text in the input field is used to send a chat message.

In bothe cases, the script prevents the default action (the form submition) from taking place.

Let's look where the client's connection is created:

    function onsubmit(e) {
        // ...
        if(ws && ws.readyState == 1) {
            // ... (sending messages)
        } else {
            // ...
            // The `url` for the websocket - we can also statically write it in.
            var url = "ws://" + window.document.location.host +
                        '/' + $('#text')[0].value
            // Look! Here is the new connection to the websocket!
            ws = new WebSocket(url)
            // next, we set up the callback:
            ws.onopen = function(e) {
                // ...
            }
            ws.onclose = function(e) {
                // ...
            }
            ws.onmessage = function(e) {
                // ...
            }
        }

As you can see, there is a similarity here. In Javascript, we open a new connection and set up it's callbacks. The callback names are very similar, although their naming convention is a bit different (singlewords instead of snake_case).

Since Javascript is single threaded, it's okay if we setup the callbacks AFTER we tell javascript to create the new connection. The new connection will be initiated only once our code is finished. This is different from Ruby and it's good to know this when working with Javascript.

The rest is common Javascript with jQuery being leveraged to make it a bit shorter to write. We simply add text to the `"output"` element as they trickle in.

## Leveraging JSON

At the moment, our websockets aren't very flexible. Our application communicates using raw strings and a single type of data.

It's true that Plezi can use binary websocket messages to give us more options, but Javascript isn't very good with binary strings... On the other hand, Javascript has this great tool for seralizing objects, called JSON (similar to Ruby's YAML).

We can use JSON to give our websockets more functionality. But first, let's move our single functionality to the JSON format, so we can keep what we have as we add more.

Let's update our Plezi application to use JSON.

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
            case msg['type']
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
                type: 'chat',
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

We also need to update our `on_open` and `on_close` to use JSON... This might be a good time to introduce a new type of message... It could, if we want it to, look something like this:

    class ChatServer
        def on_open
            unless params[:id]
                emit type: 'err', data: "You need a nickname to join the chat!"
                return close
            end
            # lets sanitize the nickname here,
            # so we don't repeat this all the time...
            params[:id] = ::ERB::Util.html_escape(params[:id])
            # inform others
            broadcast :emit,
                    type: 'connection',
                    data: 'join'
                    from: params[:id],
                    uuid: uuid
            # welcome our client
            emit type: 'connection',
                data: 'welcome'
                from: params[:id],
                uuid: uuid
        end
        def on_close
            broadcast :emit,
                    type: 'connection',
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
                type: 'chat',
                data: ::ERB::Util.html_escape(message['data'])
        end
    end

### Client side JSON

To use JSON with javascript we will need to use `JSON.parse(e.data)` in our `onmessage(e)` callback. Our new javascript callback will look something like this (but don't follow my lead, I'm a lazy javascripter, and it's probably better to seperate this to more functions):

    ws.onmessage = function(e) {
        var msg = JSON.parse(e.data);
        switch(msg.type){
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


[todo: add unicasting / identity support]