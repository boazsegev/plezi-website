<!--<PageMap>
    <DataObject type="document">
        <Attribute name="title">A Ruby RESTful Hello World application with Plezi</Attribute>
        <Attribute name="author">Bo (Myst)</Attribute>
        <Attribute name="description">
            In this tutorial we explore how leverage Plezi to easily write a Ruby application that utilizes RESTful routing (greate for CRUD operations) and response templates (for Html/JSON responses).
        </Attribute>
    </DataObject>
    <DataObject type="thumbnail">
        <Attribute name="src" value="http://localhost:3000/images/logo_thick_dark.png" />
        <Attribute name="width" value="656" />
        <Attribute name="height" value="256" />
    </DataObject>
</PageMap>-->
# The Hello World OVERKILL!

If you read [the getting started guide](./basics), you know that a "Hello World" Plezi applicationonly needs two line (three, if you're using `irb` instead of a ruby script)... remember?

    require 'plezi'
    route('*') { "Hello World!" }
    exit # <- this exits the terminal and starts the server

So... instead of writing the __shortest__ hello world tutorial, we're going to write the most __bloated__ hello world application ever, allowing us to explore some of the more powerful and common features Plezi has to offer.

To make things more interesting, we're going to:

* Start up using a small application template, for easy deployment.
* Leverage a Controller class for our "Hello World".
* Use a template file to render our data.
* Use a layout for all our Html rendered pages.
* Handle 404 errors gracefully.
* Add an AJAX JSON (AJAJ) rewite-route to set our reponse format.
* Send the response in JSON format when requested (using the power of templates and layouts).
* Install a Markdown render engine and use that instead of our original html render engine (but we will keep the layout).

Get ready to write the most bloated, feature rich, "hello world" application and discover how easy it can be to support all these features when using Plezi.

## Create a starter application

Plezi provides us with a jump start, so that we can begin coding straight away and not spend time on creating folders and writing the same stuff over and over again.

We can use either:

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
        wrote ./assets/plezi_client.js
    done.

    please change directory into the app directory: cd hello_world

    run the hello_world app using: ./hello_world or using: plezi s

Great. We have something to start with.

Let's take a quick look over the files:

* `hello_world` - This is a cool short-cut for unix based systems, such as Mac OS X. You can double click this file to start your application - ain't that cool?

* `hello_world.rb` - This is our actual application. We should look into this file as we change things.

* `Procfile` - Some PaaS providers, such as Heroku, use a Procfile to decide how to start our application and how many instances to run etc'... This is here to help us with a quick deployment.

* `Gemfile` - The Gemfile should be really well known if you've used Ruby before. Ruby allows you to extend your code with Ruby libraries called "gems". Plezi is a gem and you're using it to simplify your life and a Ruby programmer.

* `templates/404.html.erb` - This is a template for the 404 file not found errors. We'll see this if we request something our application doesn't have. We'll get rid of it later on.

* `templates/500.html.erb` - This is a template for the 500 internal server errors. We'll aee this page quite a lot as we debug our applications. The page won't show us the errors (that's what the terminal is for), but it will let us know something was broken in our code.

* `templates/welcome.html.erb` - This is Plezi's welcome page. As the name suggests, it's an Html template using the ERB (embeded Ruby) templating engine. This Html and Javascript page is actually a chat-room client application. We're going to wreck havoc on this, because we'll want it to say "Hello World".

* `assets/websocket.js` - This is stub code for websocket connections. We can update this code and include it in our Html for a quick websocket client.

Now, let's double click on the `hello_world` to start our application (or run `./hello_world` from our terminal).

Next, open a new browser window or two and visit [localhost:3000](http://localhost:3000) to see what we've got. We can use two browser windows to chat with ourselves...

Congratualations! We've created a Plezi application. It's a chat room and we want it to be something different, but it's a start :-)

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

This approach will let us do some really funky things very easily... But first, low and behold our somewhat (but not quite) bloated "Hello World". Run the app and bask in it's glory.

### Hello RESTful requests

The world is a very interesting place, with many continents and places inside... Wouldn't we want our "Hello World!" to be a little more flexible? Sure we do.

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

Now, restart the application and visit: [localhost:3000/New York](http://localhost:3000/New%20York), [localhost:3000/London](http://localhost:3000/London) and [localhost:3000/Atlantis](http://localhost:3000/Atlantis) (Always wanted to go there)...

`show` isn't the only RESTful method, you can read our [guide about Controllers](./controllers) or view the [stub code at Plezi::StubRESTCtrl and Plezi::StubWSCtrl](https://github.com/boazsegev/plezi/blob/master/lib/plezi/handlers/stubs.rb) to learn more about reserved methods.

Just one last thing... Atlantis isn't really here no more... let's make it a special case by adding a dedicated method for this `:id`. Also, let's replace `cookies` with a short-lived cookie-flavor called `flash` (a self-destructing cookie):

    class HelloController
        def index
            redirect_to :World
        end
        def show
            response << "You came from #{flash[:hello]}. now...\n" if flash[:hello]
            flash[:hello] = params[:id]
            "Hello #{params[:id]}!"
        end
        def atlantis
            # notice what happens when we don't set the flash.
            "Dude! It sunk!"
        end
    end

Now, let's restart the application and re-visit: [localhost:3000/London](http://localhost:3000/London) and [localhost:3000/Atlantis](http://localhost:3000/Atlantis)<sup>*</sup> - This was cool!

\* Make sure to click the links to the pages and not manually type the addresses in your browser. Today's browsers have "predictive" loading and they will start requesting all sorts of pages while you're still typing, causing the cookie data to change with every attempted "guess".

## Moving the View out of the Controller

Now, we kinda' made a wrong turn somewhere along the way, when our controller started to format our response directly, instead of levereging templates.

Also, we should probably be using Html instead for clear text.

As we format our response for Html, we would probably want to seperate all the common stuff from our actual content - this is a very useful and common approach that allows us to update the design and flow of our formatted response using a global (or semi global) layout.

### Using templates

If you'll look through `hello_world.rb`, you should find these little lines:

    host templates: Root.join('templates').to_s,
        # public: Root.join('public').to_s,
        assets: Root.join('assets').to_s

These lines set some common options for our global host. Yes, since you wondered, Plezi supports virtual hosts, each with their own settings and unique - or shared - routes.

As we can see, our application already has a `templates` folder setup, so all we need is to write our layout and content templates and update our Controller to use them.

#### The updated controller

To use templates in our controller, we will leverage the `HelloController#render` method (didn't know we had one, did you? - well, we do). Just like the `HelloController#redirect_to` method which we used, this method was also "injected" into our controller when Plezi inherited our code.

The method accepts a number of common options such as `:layout`, `:type` and `:locale`.

Here's a bit of an updated controller... while we're at it, we should probably sanitize any incoming data, who knows what our users might do when our application's security is tested in the big wild internet:

    class HelloController
        def index
            redirect_to :World
        end
        def show
            @location = ::ERB::Util.html_escape params[:id]
            @previous = ::ERB::Util.html_escape flash[:hello]
            flash[:hello] = params[:id]
            render :hello, layout: :layout
        end
        def atlantis
            @location ="Dude! It sunk!"
            @previous = ::ERB::Util.html_escape flash[:hello]
            render :hello, layout: :layout            
        end
    end


#### The layout

I will be using the `ERB` (embeded ruby) engine for this demo, but on my own applications I usually go with [`Slim`](http://slim-lang.com). You can use Slim too, just add it to your gemfile. It's supported right out of the box.

Our html layout file will be saved as `layout.html.erb` and it looks something like this:

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title><%= @title || "Hello World" %></title>
        </head>
        <body>
            <%= yield %>
        </body>
    </html>

If you're using [Slim](http://slim-lang.com), maybe you saved the layout as `layout.html.slim`, and it might have looked like this:

    doctype html
    html
        head
            meta charset="utf-8"
            title= @title || "Hello World"
        body
            == yield

#### The content template

The content is super short for "Hello World", it's a one or two paragraph long file called `hello.html.erb`:

    <% if @previous %>
    <p>We just arrived from <%= @previous %>, we welcome you!</p>
    <% end %>
    <p>Hello <%= @location %>!</p>


Cool. Let's see it in action, this time visiting [localhost:3000/Berlin](http://localhost:3000/Berlin), [localhost:3000/Paruge](http://localhost:3000/Paruge) and [localhost:3000/Atlantis](http://localhost:3000/Atlantis).

## Handling errors more gracefully

I showed my friend our amazing "Hello World" app, and he decided to visit [localhost:3000/Miami/Beach](http://localhost:3000/Miami/Beach)...

Since our controller only answers to requests that look like `"/(:id)"` and since his request looked like `"/(:id)/Beach"`, this brought up a blue sceen with the famous Http 404 (not found) error.

I think our application could have handled the error more gracefully, keeping everything "in house", as it were.

The same goes for handling internal server errors (error code 500). We don't want anything to look as if our application isn't the one in control.

### A graceful 404 error

Looking at the files in our `hello_world` applications, we can find a template called `404.html.erb`. The 404 (not found) error seems to be routed to the `404.html.erb` tamplate. 

We have a number of ways to deal with the error more gracefully... Personally, I'm an advocate for the lazy method, which we will use when dealing with the 500 (internal error) error.

For now, lets update our `hello_world.rb` file and add a "catch-all" route at the end of our file, after our home page route.

A catch-all route doesn't have an `:id` appended to it, so our Controller only needs to implement one method: `index`.

First, let's create a Controller, We'll call it `Err404Ctrl` and save it in a file in our `app` folder. Let's name the file `app/err404.rb`:

    class Err404Ctrl
        def index
            @previous = flash[:hello]
            @location = "Nowhere (error 404 - location not found)"
            render :hello, layout: :layout
        end
    end

Now, let's update out `hello_world.rb` file. We will add the following line at the end of our file:

    Plezi.route '*', Err404Ctrl

Maybe you looked at the line above the one we just added and saw that it read:

    route '/', HelloController


Wonder why we write `Plezi.route` instead of `route`? - No special reason, except to show where the `route` method actually comes from.

Cool, we now handle the 404 not found error way more gracefuly. Try it: [localhost:3000/Miami/Beach](http://localhost:3000/Miami/Beach)

### a graceful 500 error

Now, 500 errors also creep up sometimes and that's when the s**t really hit's the fan.

Let's make sure we get an 500 error whenever we want one by adding the following method to our HelloController class:

    class HelloController
        # ... all our existing code is here
        def fail
            raise "HELL!"
        end
    end

Now (remember to restart the application), if we visit [localhost:3000/fail](http://localhost:3000/fail) we should get the `500.html.erb` template.

Here we might have to get creative... but no worries, Plezi has us covered. You see, Plezi uses a class called ErrorCtrl to render the error template... By it's name, yap, you guessed it, it's a controller!

This means that our error templates are rendered within the context of a controller class and we have full access to all of our favorite helper methods, including `render`, `redirect_to`... the whole bunch.

Let's update our `500.html.erb` template file, so it reads:

    <%=
        @previous = flash[:hello]
        @location = "Nowhere... we had an internal error. Sorry"
        render :hello, layout: :layout
    %>

If we're feeling adventurous, we can update it even a little further:

    <%=
        @previous = flash[:hello]
        @location = "Nowhere... we had an internal error. Sorry"
        render :hello, layout: :layout
    %>
    <%=
        # We can use Ruby's global "last exception backtrace" variable.
        $@.join("<br/><br/>") if request.base_url =~ /localhost/
    %>

Done! Now restart the application and visit [localhost:3000/fail](http://localhost:3000/fail) - ain't managing errors easy?

## What about AJAX-JSON clients?

Managing the format of the response with Plezi is super easy.

First, I'll demonstrate the concept and than we'll do it the right way.

Keep the aplication running, for now we won't change even a single line of code.

Add the following to files to your template's folder: `layout.json.erb` and `hello.json.erb`

`layout.json.erb` might look (for now) something like this:

    <%= yield %>

`hello.json.erb` might look something like this:

    <%=
    {
        from: @previous,
        location: @location
    }.to_json
    %>

Now, run the app and visit any location while adding at the end of the path `?format=json` (we'll fix this later). i.e.: [localhost:3000/Miami?format=json](http://localhost:3000/Miami?format=json)

Wow! Plezi automatically recognized the request is for a different format and chose the correct templates - sweet (`:format` and `:locale` are often used this way, so Plezi recognizes this convention).

But, the whole `?format=json` doesn't really look nice. Let's fix that.

### Using re-write routes to re-format the request

Plezi has this really cool feature that's called "rewrite routes". It allows us to extract parameters from the **beginning** of the request and make them available for all the other routes.

Rewrite routes also rewrite the request path, so future routes don't see the original request's path (available as `request.original_path`). This way, our routes work exacly the same as if the parameters were added using the ugly way (we don't need to update them in any way).

All we need is to create a route and pass `false` as our controller - easy.

This allows us to set the language for all our routes by adding a single rewrite route such as:

    route '/(:locale){en|it|ru}', false

This also allows us to support JSON across the board with a single rewrite route and a few templates.

We will add the `route "/(:format){html|json}" , false`  rewrite route as the **first** route - remember, routes have priority by order of creation... so we want our request to be re-written before it's reviewed by our other routes.

Our routing code, in `hello_world.rb` should now look like this:

    host templates: Root.join('templates').to_s,
        assets: Root.join('assets').to_s
    route "/(:format){html|json}" , false
    route '/(:id)', HelloController
    Plezi.route '*', Err404Ctrl

That's it! restart the app and go to [localhost:3000/json/London]([http://localhost:3000/json/london)

Notice how the old path, [localhost:3000/London]([http://localhost:3000/London), gracefully remains intact, rendering our html (the default format for the web).

### Sending the data in JSON format

But wait... there's a reason we use a layout.

Even when using JSON, there is usually some common data we will want to send together with all our responses.

Now, we know `render` returns the text that was rendered, so how do we combine both of the strings to return a single JSON stream?

Here's one way (the simple way) - we render the JSON in the template and parse it in the layout before adding it to our layout object.

If we do that, our JSON might look something like this:

    <%=
    {
        app: 'hello world',
        version: '1',
        request: request.original_path,
        response: JSON.parse(yield)
    }.to_json
    %>

But... this isn't very effective as far as performance goes.

Another way is to "hack" the JSON format.

We know what a simple Hash looks like in JSON (`'{"key":"value"}'`) - why not simply edit the string directly by cutting the end of the string (so we have `'{"key":`), adding the Hash (so we have `'{"key":{"key":"value"}`) and than closing it back with a `'}'`?

This did require a bit of knowledge about JSON, but now you know it and you can use it too. So let's update our layout to make it perform better (yes, even this can be improved quite a bit):

    <%=
    {
        app: 'hello world',
        version: '1',
        request: request.original_path,
        response: ''
    }.to_json[0..-4] + yield + '}'
    %>

Supporting other formats with Plezi is easy.

## Hello Markdown - Using a custom render engine

If you decide to look at [the code for plezi.io's website](https://github.com/boazsegev/plezi-website), you'd probably come across a few interesting facts.

1. You would probably notice that all the guides are written in Markdown, meaning they must be dynamically rendered to Html.

2. You would notice that there are no templates for the table of contents at the top of each of the guides, but that one is always present. This could have been achieved "client-side" as well (SEO aside), but it obviously wasn't... so the rendering engine must have been costumized to do that.

3. You would notice that the markdown files and the table of contents are all rendered using a single command: `render`.

This customization is the product of the following few lines that were misplaced an an obscure file called `render_markdown.rb`:


    # create a single gloabl renderer for all markdown files.
    MD_RENDERER = Redcarpet::Markdown.new NewPageLinksMDRenderer.new(with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true
    # was: MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML.new( with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true

    # create a single gloabl renderer for all markdown TOC.
    MD_RENDERER_TOC = Redcarpet::Markdown.new Redcarpet::Render::HTML_TOC.new()

    # register the Makrdown renderer with some Github flavors (but not the official Github Renderer)
    ::Plezi::Renderer.register :md do |filename, context, &block|
        data = IO.read filename
        Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, "<div class='toc'>#{MD_RENDERER_TOC.render(data)}</div>\n#{::MD_RENDERER.render(data)}" )  : (Plezi.get_cached filename)
    end

This code I decided to use is highly customized, since I wanted to both add and style a table of contents for each of the pages and even wanted to distinguish local links (that open in the same window) from remote links (that should open in a new windows tab)... Anyway, a simplified version would look like this:

    # a global render engine
    MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML.new( with_toc_data: true),
            autolink: true, fenced_code_blocks: true, no_intra_emphasis: true,
            tables: true, footnotes: true

    # register the `md` extention (Makrdown) to be rendered using Plezi's `render`.
    ::Plezi::Renderer.register :md do |filename, context, &block|
        data = IO.read filename
        if Plezi.cache_needs_update?(filename)
            Plezi.cache_data ::MD_RENDERER.render(data)
        else
            Plezi.get_cached filename
        end
    end

Wow! We discovered that Plezi has caching helpers (even one that checks if the file that initiated the cache was updated since we cached our data) AND that Plezi's `render` method can be extended to render any extention we want.

As an excersize, try and complete this one yourself: update your Html `hello` template to use markdown instead of ERB of Slim. What do you think should change (notice the difference between `erb` and `slim` usage?


