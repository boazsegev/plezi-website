# The "Hello World" OVERKILL!

If you read [the overview](/guides/basics), you know that a "Hello World" Plezi applicationonly needs two line (three, if you're using `irb` instead of a ruby script)... remember?

    require 'plezi'
    route('*') { "Hello World!" }
    exit # <- this exits the terminal and starts the server

So... what the hell do we have to write about? Well...

To make things more interesting, we're going to:

* Start up using a small application template, for easy deployment.
* Leverage a Controller class for our "Hello World".
* Use a template file to render our data.
* Use a layout for all our Html rendered pages (yes, there will be only one).
* Handle 404 errors gracefully.
* Add an AJAX JSON rewite-route to set our reponse format.
* Send the response in JSON format when requested.
* Install Github's render engine and use that instead of our original render engine (but we will keep the layout).

Hmmm... I'm still thinking about more ideas, but this seems like a fun start.

[todo: write the damn thing ;-)]

## Create a starter application

Plezi provides us with a jump start, so that we can begin coding straight away and not spend time on creating folders and writing the same stuff over and over again.

We and use either:

    $ plezi mini appname

Or:

    $ plezi new appname

Personally, I like to start small and grow, so we will create our applications usig the smaller template. Open the terminal window (bash) and type:

    $ plezi mini hello_world

You should get a response on your terminal, something along these lines:

    created the hello_world application directory.
    starting to write template data...

        wrote ./hello_world
        wrote ./hello_world.rb
        wrote ./Procfile
        wrote ./Gemfile
        created ./templates
        wrote ./templates/404.html.erb
        wrote ./templates/500.html.erb
        wrote ./templates/welcome.html.erb
        created ./assets
        wrote ./assets/websocket.js
    done.

    please change directory into the app directory: cd hello_world

    run the hello_world app using: ./hello_world or using: plezi s

Great. We have something to start with.

Let's take a quick look over the files:

* `hello_world` - This is a cool short-cut for unix based systems, such as Mac OS X. You can double click this file to start your application - ain't that cool?

* `hello_world.rb' - This is our actual application. We should look into this file as we change things.

* `Procfile` - Some PaaS providers, such as Heroku, use a Procfile to decide how to start our application and how many instances to run etc'... This is here to help us with a quick deployment.

* `Gemfile` - The Gemfile should be really well known if you've used Ruby before. Ruby allows you to extend your code with Ruby libraries called "gems". Plezi is a gem and you're using it to simplify your life and a Ruby programmer.

* `templates/404.html.erb` - This is a template for the 404 file not found errors. We'll see this if we request something our application doesn't have. We'll get rid of it later on.

* `templates/500.html.erb` - This is a template for the 500 internal server errors. We'll aee this page quite a lot as we debug our applications. The page won't show us the errors (that's what the terminal is for), but it will let us know something was broken in our code.

* `templates/welcome.html.erb` - This is Plezi's welcome page. As the name suggests, it's an Html template using the ERB (embeded Ruby) templating engine. This Html and Javascript page is actually a chat-room client application. We're going to wreck havoc on this, because we'll want it to say "Hello World".

* `assets/websocket.js` - This is stub code for websocket connections. We can update this code and include it in our Html for a quick websocket client.

Now double click on the `hello_world` to start our application (or run `./hello_world` from your terminal).

Next, open a new browser window or two and visit [localhost:3000](http://localhost:3000) to see what we've got. You can use two broser windows to chat with yourself...

Congratualations! You've created a Plezi application. It's a chat room and we want it to be something different, so let's move on.

## Saying Hello directly from the Controller

[todo: write]

### Organizing our controller code

[todo: write]

## Moving our response to a template

[todo: write]

## Using a layout

[todo: write]

## Handling 404 errors more gracefully

[todo: write]

## What about AJAX/JSON clients?

[todo: write]

### Using re-write routes to set the response's format

[todo: write]

### Sending the data in JSON format

[todo: write]

## Hello Markdown - Using a custom render engine

[todo: write]


