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

I love starting small and growing, and Plezi follows the same spirit, provoding a minimalist skelaton for new applications, allowing the applications to grow as new features are actually required (rather then assumed). The following command will provide us with a good minimal skelaton:

    $ plezi new appname

That's it, we now have a our first Plezi application - it's a websocket chatroom (that's the starter code).

On MacOS or linux, simply double click the `appname` script file to start the server. Or, from the terminal:

    $ cd appname
    $ ./appname

See it work: [localhost:3000/](http://localhost:3000/)

## Plezi is so easy, we can code an app in the terminal!

The Plezi framework was designed with intuitive ease of use in mind.

We'll explore a more "robust" `Hello World` example in our [Hello world tutorial](./hello_world), but here's a kicker... open `irb` and type (or copy & paste) the following:

```ruby
require 'plezi'
class Demo
   def index
      "Hello World!"
   end
end
Plezi.route '*', Demo
exit # <- this exits the terminal and starts the server
```
Now visit [localhost:3000](http://localhost:3000/)

The server auto-starts, sweet. This allows us to write small micro-services without writing a single line of code for the network layer :-)

## Object Oriented design is fun!

While Plezi allows us to utilize methods, like we just did, Plezi really shines when we use Controller classes.

Plezi will automatically map public instance methods in any class to routes with complete RESTful routing support.

Let's copy and paste this into our `irb` terminal:

```ruby
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
        "Are you looking for: #{params['id']}?"
    end
end

Plezi.route '/', MyDemo
exit
```

Now visit [index](http://localhost:3000/) and [foo](http://localhost:3000/foo) or request an id, i.e. [localhost:3000/1](http://localhost:3000/1).

Did you notice how the controller has natural access to the request's `params`?

This is because Plezi inherits our controller and adds some magic to it, allowing us to read _and set_ cookies using the `cookies` Hash based cookie-jar, look into the `request`, set special headers for the `response`, etc'

## Can Websockets do that?!

Plezi was designed for websockets from the ground up. If your controller class defines sets the `@auto_dispatch` class variable or defines an `on_message(data)` callback, plezi will automatically enable websocket connections for that route.

Here's a Websocket echo server using Plezi:

```ruby
require 'plezi'
class MyDemo
    def on_message data
        # sanitize the data and write it to the websocket.
        write ">> #{ERB::Util.html_escape data}"
    end
end

Plezi.route '/', MyDemo
exit
```

Plezi will also, automatically, route the controller's (public and protected) instance methods to websocket events which you can "fire" using the `unicast`/`broadcast` methods.

Why protected methods, you ask? ... well, We wouldn't want any miscreant users using HTTP requests to activate websocket events. This is why both public and protected methods are available for websocket events, but only public methods are available for HTTP.

Each controller can also act as a "channel", broadcasting websocket events (controller protected methods) to everyone who's connected to it.

Here's a websocket chat-room server using Plezi, complete with minor authentication (requires a chat handle):

```ruby
require 'plezi'
class MyDemo

    def on_open
        # there's a better way to require a user handle, but this is good enough for now.
        close unless params['id']
    end

    def on_message data
        # broadcast to everyone else (NOT ourselves):
        # this will have every connection execute the `chat_message` with the following argument(s).
        broadcast :chat_message, "#{params['id']}: #{data}"
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

Plezi.route '/', MyDemo
# You can connect to this chatroom by going to ws://localhost:3000/any_nickname
# but you need to write a websocket client too...
# try two browsers with the client provided by http://www.websocket.org/echo.html
# (don't use the www.websocket.org SSL version, as our server isn't running SSL)
exit
```

Broadcasting isn't the only tool Plezi offers, we can also send a message to a specific connection using `unicast`, or send a message to everyone (no matter what controller is handling their connection) using `multicast`...

You can read our [websockets guide](./websockets) for more information about these options.

## Websocket scaling is as easy as one line of code!

A common issue with Websocket scaling occurs when server X is trying to send websocket messages to a user connected to server Y... On Heroku, it's enough add one Dyno (a total of two Dynos) to break some websocket applications... but with Plezi, fixing this issue is easy.

Plezi leverages the power or Redis to automatically push Websocket messages across server instances, so that we can easily scale our applications (on Heroku, add Dynos) with only one line of code!

Just tell Plezi how to acess our Redis server and Plezi will make sure that our users get their messages accross different servers:

```ruby
# REDIS_URL is where Herolu-Redis stores it's URL
ENV['PL_REDIS_URL'] ||= ENV['REDIS_URL'] || "redis://:password@my.host:6389/0" # 0 is the DB selector
```

## HTTP-Websocket API

Often, when writing our applications, we want to be able to access the same data both using websockets AND using HTTP. In more common terms, we want to write an API for our service and we want it to support both XHR/AJAX (AJAJ actually) and Websockets.

Socket.io forces us to certain restrictions to achive this shared API. With Plezi, it's easy to opt-in - allowing use to decide which API will be available for websockets, which will be available for AJAX/AJAJ and which will be shared by both websockets and AJAX/AJAJ.

However, this is a bit more advanced (unless we use the `@auto_dispatch` feature), so maybe we'll get back to this later.

## Template Rendering, assets...?

Rendering allows use to seperate the View from the Controller and the data. This allows us to use the same code for different response formats (i.e., both for an html and a JSON response).

This feature is extra powerful when coupled with Plezi's rewrite routes and the `:format` parameter, that allow us to set up the format as part of the routing system.

Here's a quick example (minus the `html` and `json` templates)... We'll assume we have two templates, `index.html.slim` and `index.json.erb`.

```ruby
require 'plezi'
Plezi.templates = "/folder/to/templates"
# setup our controllers
class MyDemo
    def index
        # with the proper templates, our code is format agnostic :-)
        render('index')
    end
end
# a rewrite route
Plezi.route '/(:format)', /html|json/
# our demo route agnostic towards the output format
Plezi.route '/', MyDemo
# start the server
exit
```

Plezi supports ERB (i.e. `template.html.erb`), Slim (i.e. `template.html.slim`) and RedCarpet Markdown (i.e. `template.html.md`) straight out of the box... and it's easily extendible using the `Plezi::Renderer.register` method.
