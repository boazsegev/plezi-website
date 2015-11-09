# A Plezi chatroom using Websockets

In the landing page you have noticed a working demonstration for a fully working chatroom application, with a few lines of code executed through the `irb` terminal.

First we will walk through the code and explore it to learn more about Websockets in Plezi, than we will see what we can tweek, so that we have an application we can deploy to a PaaS (I'll demostrate using Heroku's Procfile system, but it's quite similar for most PaaS providers.

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

`host templates: path_to_client` - we are setting the `host` options for our server. More abot this in the [routes](/guide/routes) guide.

Basically we are telling Plezi where we are keeping the html (or template) that we will be sending the browser. This Html will be our "client" application. 

Because websockets are like conversations, websocket applications require (at least) two sides, both "speaking" the same language. Usually there is a server and many clients. The server will be talking to all the clients, sometimes also delivering messages between clients.

The web page is the "client" for our web application. and the `path_to_client` tells Plezi where to look for the template.

`route '/', ChatServer` - We are connecting the `"/"` path to our `ChatServer` controller.

Actually, since Plezi is quite opinionated about it's routes, Plezi assumes we meant to write `"/(:id)"`, meaning that the optional `params[:id]` can be set using our route.

Our `ChatServer` will actually answer a request such as (for example) `"/my-name"` and will set the `params[:id]`'s value to be `"my-name"`.

### Sending the client

The following method answers the path `'/'` (the index path, no `:id`) by "rendering" our template into an html file and sending it.

    class ChatServer
        def index
            render :client
        end
    end

`render` will automatically look up a file named `"client.html.erb"` in the `templates` folder we set up before, when calling `host`.

Actually, `render` will also look for `"client.html.slim"` and `"client.html.haml"` if we include these gems in our `Gemfile`.

### Establishing a connection

[todo: explain the code from the landing page, demonstrate JSON]