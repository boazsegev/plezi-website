# A Plezi chatroom using Websockets

Just like the ["Hello World" tutorial](./hello_world) was used to explore some of what Plezi had to offer us in the world of Http and RESTful routing, this Chatroom tutorial can be used to explore what Plezi can do for us when it comes to websockets.

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

    This is a "hallway" type of authentication (you can enter the hallway, but you're not inside just yet).

    The advantage of this approach is that it allows us to send back authentication error messages using our websocket connection as well as unify any initialization we need with the authentication.

In this example, our authentication process is simple, we just make sure our client has a nickname by using the `params[:id]` or we close the connection (remember Plezi's RESTful routing?).

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


[todo: explain the code from the landing page, demonstrate JSON]