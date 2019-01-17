# Plezi - the Ruby framework for realtime web-apps
[![Gem Version](https://badge.fury.io/rb/plezi.svg)](http://badge.fury.io/rb/plezi) [![Inline docs](http://inch-ci.org/github/boazsegev/plezi.svg?branch=master)](http://www.rubydoc.info/github/boazsegev/plezi/master) [![GitHub](https://img.shields.io/badge/GitHub-Open%20Source-blue.svg)](https://github.com/boazsegev/plezi)

Plezi is a Ruby framework for real-time web applications. It's name comes from the word "pleasure", since Plezi is a pleasure to work with.

With Plezi, you can easily:

1. Create a Ruby web application, taking full advantage of RESTful routing, HTTP streaming and scalable WebSocket features;

2. Add WebSocket services and RESTful HTTP Streaming to your existing Web-App, (Rails/Sinatra or any other Rack based Ruby app);

3. Create an easily scalable backend for your SPA.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plezi'
```

Or install it yourself as:

    $ gem install plezi

## Our first Plezi Application

I love starting small and growing. So, for my first Plezi application, I just want the basics. I will run the following in my terminal:

    $ plezi mini appname

If you prefer to have the application template already full blown and ready for heavy lifting, complete with some common settings for common gems and code snippets you can activate, open your terminal and type:

    $ plezi new appname

That's it, we now have a our first Plezi application - it's a WebSocket chat-room (that's the starter code).

On MacOS or Linux, simply double click the `appname` script file to start the server. Or, from the terminal:

    $ cd appname
    $ ./appname # ( or: plezi s )

See it work: [http://localhost:3000/](http://localhost:3000/)

## So easy, we can code an app in the terminal!

The Plezi framework was designed with intuitive ease of use in mind.

Question - what's the shortest "Hello World" web-application when writing for Sinatra or Rails? ... can you write one in your own terminal window?

In Plezi, it looks like this:

```ruby
require 'plezi'
Plezi.route('*') { "Hello World!" }
exit # <- this exits the terminal and starts the server
```

Three lines! Now visit [localhost:3000](http://localhost:3000/)

### Object Oriented design is fun!

While Plezi allows us to utilize methods, like we just did, Plezi really shines when we use Controller classes.

Plezi will automatically map instance methods in any class to routes with complete RESTful routing support.

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
        "Are you looking for: #{params[:id]}?"
    end
end

Plezi.route '/', MyDemo
exit
```

Now visit [index](http://localhost:3000/) and [foo](http://localhost:3000/foo) or request an id, i.e. [http://localhost:3000/1](http://localhost:3000/1).

Did you notice how the controller has natural access to the requests' `params`?

This is because Plezi inherits our controller and adds some magic to it, allowing us to read _and set_ cookies using the `cookies` Hash based cookie-jar, set or read session data using `session`, look into the `request`, set special headers for the `response`, store self destructing cookies using `flash` and so much more!

### Can WebSockets do that?!

Plezi was designed for WebSockets from the ground up. If your controller class defines an `on_message(data)` callback, plezi will automatically enable WebSocket connections for that route.

Here's a WebSocket echo server using Plezi:

```ruby
require 'plezi'
class MyDemo
    def on_message data
        # sanitize the data and write it to the WebSocket.
        write ">> #{ERB::Util.html_escape data}"
    end
end

Plezi.route '/', MyDemo
exit
```

But that's not all, each controller is also a "channel" which can broadcast to everyone who's connected to it.

Here's a WebSocket chat-room server using Plezi, complete with minor authentication (requires a chat handle):

```ruby
require 'plezi'
class MyDemo
    def on_open
        # there's a better way to require a user handle, but this is good enough for now.
        return close unless params[:id]
        subscribe :chat
    end
    def on_message data
        # sanitize the data.
        data = ERB::Util.html_escape data
        publish :chat, "#{params[:id]}: #{data}"
    end
end

Plezi.route '/', MyDemo
# You can connect to this chat-room by going to ws://localhost:3000/any_nickname
# but you need to write a WebSocket client too...
# try two browsers with the client provided by http://www.WebSocket.org/echo.html
exit
```

### WebSocket scaling is as easy as one line of code!

A common issue with WebSocket scaling is trying to send WebSocket messages from server X to a user connected to server Y... On Heroku, it's enough add one Dyno (a total of two Dynos) to break some WebSocket applications.

Plezi leverages the power or Redis to automatically push both WebSocket messages and HTTP session data across servers, so that you can easily scale your applications (on Heroku, add Dynos).

The easiest and recommended approach is to set up Redis using the command line option when starting iodine:

    iodine -r "redis://:password@my.host:6389"

### Hosts, template rendering, assets...?

Plezi allows us to use different host-names for different routes. i.e.:

```ruby
require 'plezi'

host # this is the default host, it's always last to be checked.
Plezi.route('/') {"this is localhost"}

host host: '127.0.0.1' # special host, for the IP name
Plezi.route('/') {"this is only for the IP!"}
exit
```

Each host has it's own settings for a public folder, asset rendering, templates etc'. For example:

```ruby
require 'plezi'

class MyDemo
    def index
        # to make this work, create a template and set the correct template folder
        render :index
    end
end

Plezi.templates = File.join('my', 'templates', 'folder'),
Plezi.assets = File.join('my', 'assets', 'folder')

Plezi.route '/assets', :assets
Plezi.route '/', MyDemo
exit
```

Plezi supports ERB (i.e. `template.html.erb`), Slim (i.e. `template.html.slim`), Haml (i.e. `template.html.haml`), CoffeeScript (i.e. `asset.js.coffee`) and Sass (i.e. `asset.css.scss`) right out of the box... and it's even extendible using the `Plezi::Renderer.register` and `Plezi::AssetManager.register`

## More about Plezi Controller classes

One of the best things about the Plezi is it's ability to take in any class as a controller class and route to the classes methods with special support for RESTful methods (`index`, `show`, `new`, `save`, `update`, `delete`, `before` and `after`) and for WebSockets (`pre_connect`, `on_open`, `on_message(data)`, `on_close`, `publish`, `subscribe`, `unsubscribe`).

Here is a Hello World using a Controller class (run in `irb`):

```ruby
require 'plezi'

class Controller
    def index
        "Hello World!"
    end
end


Plezi.route '*' , Controller

exit # Plezi will autostart once you exit irb.
```

Except when using WebSockets, returning a String will automatically add the string to the response before sending the response - which makes for cleaner code. It's also possible to use the `response` object to set the response or stream HTTP (return true instead of a stream when you're done).

It's also possible to define a number of controllers for a similar route. The controllers will answer in the order in which the routes are defined (this allows to group code by logic instead of url).

\* please read the demo code for Plezi::StubRESTCtrl and Plezi::StubWSCtrl to learn more. Also, read more about the [Iodine's WebSocket and HTTP server](https://github.com/boazsegev/iodine) at the core of Plezi to get more information about the amazing [Request](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/HTTP/Request) and [Response](http://www.rubydoc.info/github/boazsegev/iodine/master/Iodine/HTTP/Response) objects.

## Native WebSocket, Pub/Sub and Redis support

Plezi Controllers have access to native WebSocket support through the `pre_connect`, `on_open`, `on_message(data)`, `on_close`, `subscribe`, and `publish` API.

## Adding WebSockets to your existing Rails/Sinatra/Rack application

You already have an amazing WebApp, but now you want to add WebSocket or pub/sub support - Plezi makes connecting your existing WebApp with your Plezi WebSocket backend as easy as it gets.

As explained [here](./with_rack_app), Plezi can be used as middleware within your existing application - it's as easy as that.

## Plezi Routes

Plezi supports magic routes, in similar formats found in other systems, such as: `route "/:required/(:optional_with_format){[\\d]*}/(:optional)", Plezi::StubRESTCtrl`.

Plezi assumes all simple routes to be RESTful routes with the parameter `:id` ( `"/user" == "/user/(:id)"` ).

```ruby
require 'plezi'

# this route demos a route for listing/showing posts,
# with or without revision numbers or page-control....
# notice the single quotes (otherwise the '\' would need to be escaped).
Plezi.route '/post/(:id)/(:revision){[\d]+\.[\d]+}/(:page_number)', Plezi::StubRESTCtrl
```

now visit:

* [http://localhost:3000/post/12/1.3/1](http://localhost:3000/post/12/1.3/1)
* [http://localhost:3000/post/12/1](http://localhost:3000/post/12/1)

**[please see the `route` documentation for more information on routes](/docs/routes)**.

## Re-write Routes

Plezi supports special routes used to re-write the request and extract parameters for all future routes.

This allows you to create path prefixes which will be removed once their information is extracted.

This is great for setting global information such as internationalization (I18n) locales.

By using a route with the a 'false' controller, the parameters extracted are automatically retained.

\*(Older versions of Plezi allowed this behavior for all routes, but it was deprecated starting version 0.7.4).

```ruby
require 'plezi'

class Controller
    def index
        return "Bonjour le monde!" if params[:locale] == 'fr'
        "Hello World!\n #{params}"
    end
    def show
        return "Vous êtes à la recherche d' : #{params[:id]}" if params[:locale] == 'fr'
        "You're looking for: #{params[:id]}"
    end
    def debug
        # binding.pry
        # do you use pry for debuging?
        # no? oh well, let's ignore this.
        false
    end
    def delete
        return "Mon Dieu! Mon français est mauvais!" if params[:locale] == 'fr'
        "did you try #{request.base_url + request.original_path}?_method=delete or does your server support a native DELETE method?"
    end
end

# this is our re-write route.
# it will extract the locale and re-write the request.
Plezi.route '/:locale{fr|en}/*', false

# this route takes a regular expression that is a simple math calculation
# (calculator)
#
# it is an example for a Proc controller, which can replace the Class controller.
Plezi.route /^\/[\d\+\-\*\/\(\)\.]+$/ do |request, response|
    message = (request.params[:locale] == 'fr') ? "La solution est" : "My Answer is"
    response << "#{message}: #{eval( request.path[1..-1] )}"
end

Plezi.route "/users" , Controller

Plezi.route "/" , Controller
```
try:

* [http://localhost:3000/](http://localhost:3000/)
* [http://localhost:3000/fr](http://localhost:3000/fr)
* [http://localhost:3000/users/hello](http://localhost:3000/users/hello)
* [http://localhost:3000/users/(5+5*20-15)/9.0](http://localhost:3000/users/(5+5*20-15)/9.0) - should return a 404 not found message.
* [http://localhost:3000/(5+5*20-15)/9.0](http://localhost:3000/(5+5*20-15)/9)
* [http://localhost:3000/fr/(5+5*20-15)/9.0](http://localhost:3000/fr/(5+5*20-15)/9)
* [http://localhost:3000/users/hello?_method=delete](http://localhost:3000/users/hello?_method=delete)

As you can see in the example above, Plezi supports Proc routes as well as Class controller routes.

Please notice that there are some differences between the two. Proc routes are less friendly, but plenty powerful and are great for custom 404 error handling.

## OAuth2 and other Helpers

Plezi has a few helpers that help with common tasks.

For instance, Plezi has a built in controller that allows you to add social authentication using Google, FaceBook
and and other OAuth2 authentication service. For example:

```ruby
require 'plezi'

class Controller
    def index
        flash[:login] ? "You are logged in as #{flash[:login]}" : "You aren't logged in. Please visit one of the following:\n\n* #{request.base_url}#{Plezi::OAuth2Ctrl.url_for :google}\n\n* #{request.base_url}#{Plezi::OAuth2Ctrl.url_for :facebook}"
    end
end

# set up the common social authentication variables for automatic Plezi::OAuth2Ctrl service recognition.
ENV["FB_APP_ID"] ||= "facebook_app_id / facebook_client_id"
ENV["FB_APP_SECRET"] ||= "facebook_app_secret / facebook_client_secret"
ENV['GOOGLE_APP_ID'] = "google_app_id / google_client_id"
ENV['GOOGLE_APP_SECRET'] = "google_app_secret / google_client_secret"

require 'plezi/oauth'

# manually setup any OAuth2 service (we'll re-setup facebook as an example):
Plezi::OAuth2Ctrl.register_service(:facebook, app_id: ENV['FB_APP_ID'],
                app_secret: ENV['FB_APP_SECRET'],
                auth_url: "https://www.facebook.com/dialog/oauth",
                token_url: "https://graph.facebook.com/v2.3/oauth/access_token",
                profile_url: "https://graph.facebook.com/v2.3/me",
                scope: "public_profile,email") if ENV['FB_APP_ID'] && ENV['FB_APP_SECRET']


create_auth_shared_route do |service_name, token, remote_user_id, remote_user_email, remote_response|
    # we will create a temporary cookie storing a login message. replace this code with your app's logic
    flash[:login] = "#{remote_response['name']} (#{remote_user_email}) from #{service_name}"
end

Plezi.route "/" , Controller

exit
```

Plezi has a some more goodies under the hood.

Whether such goodies are part of the Plezi-App Template (such as rake tasks for ActiveRecord without Rails) or part of the Plezi Framework core (such as descried in the Plezi::ControllerMagic documentation: #flash, #url_for, #render, #send_data, etc'), these goodies are fun to work with and make completion of common tasks a breeze.


## Plezi Settings

Plezi leverages [Iodine's server](https://github.com/boazsegev/iodine) new architecture. Iodine is a pure Ruby HTTP and WebSocket Server built using [Iodine's](https://github.com/boazsegev/iodine) core library - a multi-threaded pure ruby alternative to EventMachine with process forking support (enjoy forking, if your code is scaling ready).

Plezi and Iodine are meant to be very effective, allowing for much flexibility where needed.

Settings for the Iodine's core allow you to change different things, such as the level of concurrency you want (`Iodine.threads = ` or `Iodine.workers = `), security settings and more.

Settings for Iodine's HTTP and WebSockets server, allow you to change upload limits (which can be super important for security) using `Iodine::DEFAULT_SETTINGS[:max_body]`, limit WebSocket message sizes using `Iodine::DEFAULT_SETTINGS[:max_msg]`, change the WebSocket's auto-ping interval using `Iodine::DEFAULT_SETTINGS[:ping]` and more... Poke around the [iodine documentation](https://www.rubydoc.info/github/boazsegev/iodine/master/frames) ;-)

Plezi and Iodine are written for Ruby versions 2.2.2 or greater (or API compatible variants). Version 2.5.3 and above is currently recommended.

## Who's afraid of multi-threading?

Plezi builds on Iodine's concept of "connection locking", meaning that your controllers shouldn't be accessed by more than one thread at the same time.

This allows you to run Plezi as a multi-threaded (and even multi-process) application as long as your controllers don't change or set any global data... Reading global data after it was set during initialization is totally fine, just not changing or setting it...

But wait, global data is super important, right?

Well, sometimes it is. And although it's a better practice to avoid storing any global data in global variables, sometimes storing stuff in the global space is exactly what we need.

The solution is simple - if you can't use persistent databases with thread-safe libraries (i.e. Sequel / ActiveRecord / Redis, etc'), use Plezi's global cache storage (see Plezi::Cache).

Plezi's global cache storage is a memory based storage protected by a mutex for any reading or writing from the cache.

So... these are protected:

```ruby
# set data
Plezi.cache_data :my_global_variable, 32
# get data
Plezi.get_cached :my_global_variable # => 32
```

However, although Ruby seems innocent, it's super powerful when it comes to using pointers and references behind the scenes. This could allow you to change a protected object in an unprotected way... consider this:

```ruby
a = []
b = a
b << '1'
# we changed `a` without noticing
a # => [1]
```

For this reason, it's important that Strings, Arrays and Hashes will be protected if they are to be manipulated in any way.

The following is safe:

```ruby
# set data
Plezi.cache_data :global_hash, Hash.new
# manipulate data
Plezi.get_cached :global_hash do |global_hash|
    global_hash[:change] = "safe"
end
```

However, the following is unsafe:

```ruby
# set data
Plezi.cache_data :global_hash, Hash.new
# manipulate data
global_hash = Plezi.get_cached :global_hash do |global_hash|
global_hash[:change] = "NOT safe"
```

\* be aware, if using Plezi in as a multi-process application, that each process has it's own cache and that processes can't share the cache. The different threads in each of the processes will be able to access their process's cache, but each process runs in a different memory space, so they can't share.

## Contributing

Feel free to fork or contribute. right now I am one person, but together we can make something exciting that will help us enjoy Ruby in this brave new world and (hopefully) set an example that will induce progress in the popular mainstream frameworks such as Rails and Sinatra.

1. Fork it ( https://github.com/boazsegev/plezi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
