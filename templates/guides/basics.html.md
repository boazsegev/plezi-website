# A little about Plezi

Here we will explore a bit about starting up with Plezi.

First, let's introduce the Plezi application templates, they offer us a running start when we want one (which is practically always).

## Our first Plezi Application

I love starting small and growing. So, for my first Plezi application, I just want the basics. I will run the following in my terminal:

    $ plezi mini appname

If you prefer to have the application template already full blown and ready for heavy lifting, complete with some common settings for common gems and code snippets you can activate, open your terminal and type:

    $ plezi new appname

That's it, we now have a our first Plezi application - it's a websocket chatroom (that's the starter code).

On MacOS or linux, simply double click the `appname` script file to start the server. Or, from the terminal:

    $ cd appname
    $ ./appname # ( or: plezi s )

See it work: [http://localhost:3000/](http://localhost:3000/)

## Plezi is so easy, we can code an app in the terminal!

The Plezi framework was designed with intuitive ease of use in mind.

We'll explore a more "robust" `Hello World` example in our [Hello world tutorial](/guides/hello_world), but here's a kicker... open `irb` and type (or copy & paste) the following:

    require 'plezi'
    route('*') { "Hello World!" }
    exit # <- this exits the terminal and starts the server

Now visit [localhost:3000](http://localhost:3000/)

Three lines! Nice :-)

### Object Oriented design is fun!

While Plezi allows us to utilize methods, like we just did, Plezi really shines when we use Controller classes.

Plezi will automatically map instance methods in any class to routes with complete RESTful routing support.

Let's copy and paste this into our `irb` terminal:

    require 'plezi'
    class MyDemo
        # the index will answer '/'
        def index
            "Hello World!"
        end
        # a regular method will answer it's own name i.e. '/foo'
        def foo
            "Bar!"
        end
        # show is RESTful, it will answer '/(:id)'
        def show
            "Are you looking for: #{params[:id]}?"
        end
    end

    route '/', MyDemo
    exit

Now visit [index](http://localhost:3000/) and [foo](http://localhost:3000/foo) or request an id, i.e. [http://localhost:3000/1](http://localhost:3000/1).

Did you notice how the controller has natural access to the request's `params`?

This is because Plezi inherits our controller and adds some magic to it, allowing us to read _and set_ cookies using the `cookies` Hash based cookie-jar, set or read session data using `session`, look into the `request`, set special headers for the `response`, store self destructing cookies using `flash` and so much more!

### Can websockets do that?!

Plezi was designed for websockets from the ground up. If your controller class defines an `on_message(data)` callback, plezi will automatically enable websocket connections for that route.

Here's a Websocket echo server using Plezi:

    require 'plezi'
    class MyDemo
        def on_message data
            # sanitize the data and write it to the websocket.
            write ">> #{ERB::Util.html_escape data}"
        end
    end

    route '/', MyDemo
    exit

But that's not all, each controller is also a "channel" which can broadcast to everyone who's connected to it.

Here's a websocket chat-room server using Plezi, comeplete with minor authentication (requires a chat handle):

    require 'plezi'
    class MyDemo
        def on_open
            # there's a better way to require a user handle, but this is good enough for now.
            close unless params[:id]
        end
        def on_message data
            # sanitize the data.
            data = ERB::Util.html_escape data
            # broadcast to everyone else (NOT ourselves):
            # this will have every connection execute the `chat_message` with the following argument(s).
            broadcast :chat_message, "#{params[:id]}: #{data}"
            # write to our own websocket:
            write "Me: #{data}"
        end
        protected
        # receive and implement the broadcast
        def chat_message data
            write data
        end
    end

    route '/', MyDemo
    # You can connect to this chatroom by going to ws://localhost:3000/any_nickname
    # but you need to write a websocket client too...
    # try two browsers with the client provided by http://www.websocket.org/echo.html
    exit

Broadcasting isn't the only tool Plezi offers, we can also send a message to a specific connection using `unicast`, or send a message to everyone (no matter what controller is handling their connection) using `multicast`...

...It's even possible to register a unique identity, such as a specific user or even a `session.id`, so their messages are waiting for them even when they're off-line (you decide how long they wait)! We simply use `register_as @user.id` in our `on_open` callback, and than the user can get notifications sent by `notify user.id, :evet_method, *args`.

### Websocket scaling is as easy as one line of code!

A common issue with Websocket scaling is trying to send websocket messages from server X to a user connected to server Y... On Heroku, it's enough add one Dyno (a total of two Dynos) to break some websocket applications.

Plezi leverages the power or Redis to automatically push both websocket messages and Http session data across servers, so that you can easily scale your applications (on Heroku, add Dynos) with only one line of code!

Just tell Plezi how to acess your Redis server and Plezi will make sure that your users get their messages and that your application can access it's session data accross different servers:

    # REDIS_URL is where Herolu-Redis stores it's URL
    ENV['PL_REDIS_URL'] ||= ENV['REDIS_URL'] || "redis://username:password@my.host:6389"

### Hosts, template rendering, assets...?

Plezi allows us to use different host-names for different routes. i.e.:

    require 'plezi'

    host # this is the default host, it's always last to be checked.
    route('/') {"this is localhost"}

    host host: '127.0.0.1' # special host, for the IP name
    route('/') {"this is only for the IP!"}
    exit

Each host has it's own settings for a public folder, asset rendering, templates etc'. For example:

    require 'plezi'

    class MyDemo
        def index
            # to make this work, create a template and set the correct template folder
            render :index
        end
    end

    host public: File.join('my', 'public', 'folder'),
        templates: File.join('my', 'templates', 'folder'),
        assets: File.join('my', 'assets', 'folder')

    route '/', MyDemo
    exit

Plezi supports ERB (i.e. `template.html.erb`), Slim (i.e. `template.html.slim`), Haml (i.e. `template.html.haml`), CoffeeScript (i.e. `asset.js.coffee`) and Sass (i.e. `asset.css.scss`) right out of the box... and it's even extendible using the `Plezi::Renderer.register` and `Plezi::AssetManager.register`