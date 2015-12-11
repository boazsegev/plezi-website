<!--<PageMap>
    <DataObject type="document">
        <Attribute name="title">Getting started with Plezi</Attribute>
        <Attribute name="author">Bo (Myst)</Attribute>
        <Attribute name="description">
            In this tutorial we explore how to quickly write web applications with full support for Websocket, RESTful routes and CRUD operations using the Plezi Ruby framework.
        </Attribute>
    </DataObject>
    <DataObject type="thumbnail">
        <Attribute name="src" value="http://localhost:3000/images/logo_thick_dark.png" />
        <Attribute name="width" value="656" />
        <Attribute name="height" value="256" />
    </DataObject>
</PageMap>-->
# Getting started with Plezi

Here we will explore a bit about starting up with Plezi.

In just a moment, we'll open up our terminl (`irb`, `pry`, whatever you love) and run some example code - Plezi is so easy, we can write a whole application and start the server from the terminal!

But first, let's introduce the Plezi application templates, they offer us a running start when we want one - which is practically every time we're not simply testing new ideas using the terminal.

## Our first Plezi Application

I love starting small and growing. So, for my first Plezi application, I just want a basic deployemnt skeleton. I will run the following in my terminal:

    $ plezi mini appname

If you prefer to start your application with a full folder structure, ready for heavy lifting and complete with some common settings for common gems and code snippets you can activate, open your terminal and type:

    $ plezi new appname

That's it, we now have a our first Plezi application - it's a websocket chatroom (that's the starter code).

On MacOS or linux, simply double click the `appname` script file to start the server. Or, from the terminal:

    $ cd appname
    $ ./appname # ( or: plezi s )

See it work: [http://localhost:3000/](http://localhost:3000/)

## Plezi is so easy, we can code an app in the terminal!

The Plezi framework was designed with intuitive ease of use in mind.

We'll explore a more "robust" `Hello World` example in our [Hello world tutorial](./hello_world), but here's a kicker... open `irb` and type (or copy & paste) the following:

    require 'plezi'
    route('*') { "Hello World!" }
    exit # <- this exits the terminal and starts the server

Now visit [localhost:3000](http://localhost:3000/)

Three lines! Nice :-)

## Object Oriented design is fun!

While Plezi allows us to utilize methods, like we just did, Plezi really shines when we use Controller classes.

Plezi will automatically map public instance methods in any class to routes with complete RESTful routing support.

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

## Can websockets do that?!

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

Plezi will also, automatically, route the controller's (public and protected) instance methods to websocket events which you can "fire" using the `broadcast` methods.

Why protected methods, you ask? ... well, We wouldn't want any miscreant users using http requests to activate websocket events. This is why both public and protected methods are available for websocket events, but only public methods are available for http.

Each controller can also act as a "channel", broadcasting websocket events (controller protected methods) to everyone who's connected to it.

Here's a websocket chat-room server using Plezi, comeplete with minor authentication (requires a chat handle):

    require 'plezi'
    class MyDemo

        def on_open
            # there's a better way to require a user handle, but this is good enough for now.
            close unless params[:id]
        end

        def on_message data
            # broadcast to everyone else (NOT ourselves):
            # this will have every connection execute the `chat_message` with the following argument(s).
            broadcast :chat_message, "#{params[:id]}: #{data}"
            # write to our own websocket:
            # - remember to sanitize the data.
            write "Me: #{ERB::Util.html_escape data}"
        end

        protected
        # receive and implement the broadcast
        def chat_message data
            write ERB::Util.html_escape(data)
        end
    end

    route '/', MyDemo
    # You can connect to this chatroom by going to ws://localhost:3000/any_nickname
    # but you need to write a websocket client too...
    # try two browsers with the client provided by http://www.websocket.org/echo.html
    exit

Broadcasting isn't the only tool Plezi offers, we can also send a message to a specific connection using `unicast`, or send a message to everyone (no matter what controller is handling their connection) using `multicast`...

...It's even possible to register a unique identity, such as a specific user or even a `session.id`, so their messages are waiting for them even when they're off-line! We simply use `register_as @user.id` in our `on_open` callback, and than the user can get notifications sent by `notify user.id, :evet_method, *args`.

You can read our [websockets guide](./websockets) for more information about these options.

## Websocket scaling is as easy as one line of code!

A common issue with Websocket scaling occurs when server X is trying to send websocket messages to a user connected to server Y... On Heroku, it's enough add one Dyno (a total of two Dynos) to break some websocket applications... but with Plezi, fixing this issue is easy.

Plezi leverages the power or Redis to automatically push both websocket messages and Http session data across servers, so that you can easily scale your applications (on Heroku, add Dynos) with only one line of code!

Just tell Plezi how to acess your Redis server and Plezi will make sure that your users get their messages and that your application can access it's session data accross different servers:

    # REDIS_URL is where Herolu-Redis stores it's URL
    ENV['PL_REDIS_URL'] ||= ENV['REDIS_URL'] || "redis://:password@my.host:6389/0" #0 is the DB selector

## Our first Http-Websocket API

Often, when writing our applications, we want to be able to access the same data both using websockets AND using Http. In more common terms, we want to write an API for our service and we want it to support both XHR/AJAX (AJAJ actually) and Websockets.

Socket.io forces us to certain restrictions to achive this shared API. With Plezi, it's easy to opt-in - allowing use to decide which API will be available for websockets, which will be available for AJAX/AJAJ and which will be shared by both websockets and AJAX/AJAJ.

To share an API, Plezi only asks that the Http route respond using the `response` object instead of using a String as a return value. For example:

    require 'plezi'
    class MyAPI

        # this is an Http public route - must have default values
        def time forward = nil, from = nil
            # for the demo, we can also send te time to someone else
            # using unicasting:
            forward ||= params[:for]
            unicast forward, :time if forward
            # we send the response using `response <<` instead of a string.
            response << ({msg: :time, data: Plezi.time, to: uuid, from: from}).to_json
        end

        def on_message data
            begin
                # translate the message from JSON
                data = JSON.parse(data)
            rescue
                # they are not a nice client, throw them out!
                return close
            end
            case data['msg']
            when /time/i
                time data['for']
            else
                write({msg: :err, data: "not found", code: 404}.to_json)
            end
        end
    end

    route '/(:id)/(:for)', MyAPI
    # the API using browsers with the client provided by http://www.websocket.org/echo.html
    exit

To experiment with this API server (we'll skip writing a client), we'll visit the [websocket.org echo test page](http://websocket.org/echo.html), and put in the local server (ws://localhost:3000/) in the "**Location**" feild and press "**Connect**".

Next, we'll send the following message: `{"msg":"time"}`.

We should get a JSON reply with our connection's UUID, looking something like this: `{"msg":"time","data":"2015-11-16 18:28:58 -0500","to":"856___-OUR-UUID-_____00d748"}`

Cool, so far so good :-)

Now it's time to send ourselves a message.

We'll copy the uuid and keep the existing browser window and websocket connection open. Than, we'll open a new browser tab and visit `/localhost:3000/time/8___-Paste-Our-UUID-Here-_____48`

Cool! The API works! We got the time both using the Http GET request AND the websocket connection and we also managed to use the `unicast` method to send a message to a specific connection.

## Hosts, template rendering, assets...?

Plezi allows us to use different host-names for different routes. i.e.:

    require 'plezi'

    host # this is the default host, it's always last to be checked.
    route('/') {"this is localhost"}

    host host: '127.0.0.1' # special host, for the IP name
    route('/') {"this is only for the IP!"}
    exit

Each host has it's own settings for a public folder, asset rendering, templates etc'. This is great for just a single host and even better when using a distinctly different subdomain such as "admin", "blog" etc'. For example:

    require 'plezi'

    # setup our controllers
    class MyDemo
        def index
            # to make this work, create a template in the correct template folder
            render(:index) || "I'm public"
        end
    end
    class MyAdmin
        def index
            # to make this work, create a template and set the correct template folder
            render(:index) || "I'm admin"
        end
    end

    # setup our default host
    host public: File.join('my', 'public', 'folder'),
        templates: File.join('my', 'templates', 'folder'),
        assets: File.join('my', 'assets', 'folder')

    # setup our admin host
    # host names can be a String as well as a Regexp!
    host host: /^admin/i,
        public: File.join('admin', 'public', 'folder'),
        templates: File.join('admin', 'templates', 'folder'),
        assets: File.join('my', 'assets', 'folder') # we can share stuff if we want

    # setup a share route - we'll use a Regexp route - no RESTful support:
    shared_route(/^\/people\.txt$/i) { "We are the people" }

    # select our default host
    host
    # place our routes
    route '/', MyDemo

    # select our admin host
    host host: /^admin/i
    # place our routes
    route '/', MyAdmin

    # start the server
    exit

Plezi supports ERB (i.e. `template.html.erb`), Slim (i.e. `template.html.slim`), Haml (i.e. `template.html.haml`), CoffeeScript (i.e. `asset.js.coffee`) and Sass (i.e. `asset.css.scss`) right out of the box... and it's even extendible using the `Plezi::Renderer.register` and `Plezi::AssetManager.register`.