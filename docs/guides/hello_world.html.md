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

At the moment, all our application is in one file: `hello_world.rb`.

The part we're interested right now, is the `MyController#index` method. At the moment, it looks something like this:

    class MyController
        def index
            # return response << "Hello World!" # for a hello world app
            render :welcome
        end
    end

The method `MyController#render` (yes, it's an instance method) simply takes the name of a template file (more on that later) and renders the templat to a String. This string is automatically appended to the `response` object if it's the method's return value (that just makes writing Http routes easier).

Since we want to change this to "Hello World", let's update our method to return a "Hello World" string:

    class MyController
        def index
            "Hello World!"
        end
    end

While we're at it, let's set the cookie "Hello" to the value "World"... we want a very thorough message:

    class MyController
        def index
            cookies[:hello] = "world"
            "Hello World!"
        end
    end

### (re)Organizing our controller code

You know, I really don't like having all my code in one file. It makes me run through endless lines of code when I want to make changes...

Let's move our Controller to a seperate file and while where at it, let's give it a proper name.

Plezi is ready for this very common practice. In our `hello_world.rb` file you will find the following commented line - remove the comment:

    # # Load code from a subfolder called 'app'?
    Dir[File.join "{app}", "**" , "*.rb"].each {|file| load File.expand_path(file)}

Create a folder named `app` in our `hello_world` application's root folder, and crate a file with our controller code. We'll call our file `hello_controller.rb`:

    class HelloController
        def index
            cookies[:hello] = "world"
            "Hello World!"
        end
    end

Now our application is happily broken. It won't work... Why? because our Http router ([read more about routes here](./routes)) doesn't know about the new controller's name. Let's fix this.

Edit the `hello_world.rb` file again, replacing this line:

    route '/(:id)', MyController

with this line:

    route '/', HelloController

"WAIT!", I hear you say, "What happened to the `"/(:id)"`?"

Don't worry, the `"(:id)"` part is implied. Plezi always assumes RESTful routing and it will append an optional `:id` parameter to the path.

This approach will let us do some really funky things very easily... But first, low and behold your somewhat (but not quite) bloated "Hello World". Run the app and bask in it's glory.

### Hello RESTful requests

The world is a very interesting place, with many continents and places inside... Wouldn't we want our "Hello World!" to be alittle more flexible? Sure we do.

Remember the implied `:id` parameter? RESTful routing means that the method `show` will be called if the `:id` is supplied and there is no special method designated (more on that later)... Let's use this.

Let's edit our `hello_controller.rb` file:

    class HelloController
        def index
            cookies[:hello] = "world"
            "Hello World!"
        end
        def show
            cookies[:hello] = params[:id]
            "Hello #{params[:id]}!"
        end
    end

Hmm... not very DRY, is it... let's try again, and let's give more respect to the cookie while we're at it! Here's our updated code:

    class HelloController
        def index
            redirect_to :World
        end
        def show
            response << "You came from #{cookies[:hello]}. now...\n" if cookies[:hello]
            cookies[:hello] = params[:id]
            "Hello #{params[:id]}!"
        end
    end

Now, restart the application and visit: [http://localhost:3000/New%20York](localhost:3000/New York), [http://localhost:3000/London](localhost:3000/London) and [http://localhost:3000/Atlantis](localhost:3000/Atlantis) (Always wanted to go there)...

`show` isn't the only RESTful method, you can read our [guide about Controllers](./controllers) or view the [stub code at Plezi::StubRESTCtrl and Plezi::StubWSCtrl](https://github.com/boazsegev/plezi/blob/master/lib/plezi/handlers/stubs.rb) to learn more about reserved methods.

Just one last thing... Atlantis isn't really here no more... let's make it a special case by adding a dedicated method for this `:id`:

    class HelloController
        def index
            redirect_to :World
        end
        def show
            response << "You came from #{cookies[:hello]}. now...\n" if cookies[:hello]
            cookies[:hello] = params[:id]
            "Hello #{params[:id]}!"
        end
        def atlantis
            cookies[:hello] = nil
            "Dude! It sunk!"
        end
    end

Now, let's restart the application and re-visit: [http://localhost:3000/London](localhost:3000/London) and [http://localhost:3000/Atlantis](localhost:3000/Atlantis)^*^ - This was cool!

^*^ Make sure to click the links to the pages and not manually type the addresses in your browser. Today's browsers have "predictive" loading and they will start requesting all sorts of pages while you're still typing, causing the cookie data to change with every attempted "guess".

## Moving the View out of the Controller

[todo: write]

## Using a layout

[todo: write]

## Handling errors more gracefully

[todo: write]

## What about AJAX/JSON clients?

[todo: write]

### Using re-write routes to set the response's format

[todo: write]

### Sending the data in JSON format

[todo: write]

## Hello Markdown - Using a custom render engine

[todo: write]


