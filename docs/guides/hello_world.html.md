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
# Hello World in three languages

If you read [the getting started guide](./basics), you know that a "Hello World" Plezi application only needs just a few lines of code... it can be written using the `irb` terminal like so:

```ruby
require 'plezi'
class Hello
   def index
      'Hello World!'
   end
end
Plezi.route '*', Hello
exit # <- this exits the terminal and starts the server
```

So... instead of writing the __shortest__ hello world tutorial, we're going to write a "realistic" (read: __bloated__) hello world example that will allow us to say "Hello world":

* With three languages (english being the default).
* With two different formats (HTML and JSON), using templates and a format (and language) agnostic code base.
* With one codebase - formatting should only change the view, not the controller.

## Create a starter application

Plezi provides us with a jump start, so that we can begin coding straight away and not spend time on creating folders and writing the same stuff over and over again.

Let's open our terminal window and type:

    $ plezi new hello_world

You should get a response on your terminal, something along these lines:

      created the hello_world application directory.
      starting to write template data...

          wrote ./hello_world
          wrote ./hello_world.rb
          wrote ./routes.rb
          wrote ./config.ru
          wrote ./Procfile
          wrote ./Gemfile
          wrote ./rakefile
          created ./app
          wrote ./app/my_controler.rb
          created ./views
          wrote ./views/404.html.erb
          wrote ./views/500.html.erb
          wrote ./views/welcome.html.erb
          created ./public
          created ./public/javascripts
          wrote ./public/javascripts/client.js
          wrote ./public/javascripts/simple-client.js
      done.

      please change directory into the app directory: cd hello_world

      run the hello_world app using: ./hello_world or using the iodine / rackup commands.

Great. We have something to start with.

Here's the list of files that Plezi created for us. We can skip reading the list, but I'm putting it here so we can have a quick reference guide whenever we're wondering about this or that file:

* `hello_world` This is a cool short-cut for our unix based systems, such as Mac OS X. We can double click this file to start our application, even without openning the terminal window - ain't that cool?

* `hello_world.rb` - This is our actual application. We should look into this file as we change things.

* `routes.rb` - This defines the HTTP routes for our application. It's super important and we'll edit it soon. You can [read more about routes here](./routes).

* `config.ru` - By convention, Rack applications have a file named `config.ru` that is used by Rack to load the application and run it. Plezi, like most Ruby frameworks, is built on Rack. The `config.ru` allows us to use middleware with Plezi, which is quite powerful stuff.

* `Procfile` - Some PaaS providers, such as Heroku, use a Procfile to decide how to start our application and how many instances to run etc'... This is here to help us with a quick deployment.

* `Gemfile` - The Gemfile should be really well known if you've used Ruby before. Ruby allows you to extend your code with Ruby libraries called "gems" such as Plezi. The Gemfile lists the gems our application uses and allows us to easily use different gems to simplify our work.

* `app/my_controler.rb` - This file defines the first (and only) Controller for our application. It's super important and we'll edit it soon. You can [read more about controllers here](./controllers).

* `views/welcome.html.erb` - This is our application's welcome page. As the name suggests, it's an `html` template using the `ERB` (embedded Ruby) templating engine. This `html` and Javascript page is actually a chat-room client application. We're going to wreck havoc on this, because we'll want it to say "Hello World".

* `views/404.html.erb` - This is a template for any 404 file not found errors. We'll see this when we request something our application doesn't know how to serve us.

* `views/500.html.erb` - This is a template for any 500 internal server errors. We often see this page as we debug our applications. The page won't show us the errors (that's what the terminal is for), but it will let us know something was broken in our code.

* `public/javascripts/client.js` - This is the prototype code for the powerful auto-dispatch websocket client. We can use this client in our `html` responses to send and receive websocket / AJAJ events.

* `public/javascripts/simple-client.js` - This is stub code for raw websocket connections. We can update this code or use it in any `html` response, to implement a quick and raw websocket client.

Let's double click on the `hello_world` to start our application (or run `./hello_world` from our terminal).

Next, let's open a new browser window or two and visit [localhost:3000](http://localhost:3000) to see what we've got. We can use two browser windows to chat with ourselves...

Congratulations! We've created a Plezi application. It's a chat room and we want it to be something different, but it's a start :-)

## Parlez-vous français?

Pleazi created a Controller for us - located at `app/my_controler.rb` - and a landing page template - located at `views/welcome.html.erb`.

We want these to say "Hello world" in three languages:

* English (`en`): "Hello world"

* Itallian (`it`): "Ciao mondo"

* French (`fr`): "Salut le monde"

Since we know any String returned by our Controller is automatically appended to the Rack::Response (`response`) object, we can simply edit our controller for each language, something like this:

```ruby
class RootController
  # HTTP
  def index
    # any String returned will be appended to the response. We return a String.
    case params['locale']
    when 'it'
      "Ciao mondo"
    when 'fr'
      "Salut le monde"
    else
      "Hello world"
    end
  end
end
```

Although this might work, it will be no fun when we want to support 52 languages...

...However, I also don't want to install the I18n gem right now. I know the I18n gem would probably be a very good solution, we're going to keep this translation code for now. We're here to learn how to use Plezi, we can always revisit this code later on.

Let's restart our application and visit:

* [localhost:3000/?locale=fr](http://localhost:3000/?locale=fr)

This is okay but... well... it's Ugly. The URL looks ugly and there's no HTML formatting... Let start with fixing that URL, shall we?

## Rewriting the route

Plezi supports inline route parameters. So we could edit our `routes.rb` file to be something like this:

```ruby
Plezi.route ':locale', RootController
```

But then we have to always use a locale, which is ugly in a different way and means the root path (`'/'`) just became invalid... besides, when we have 15 routes, we will have to keep writing `:locale` every time, which is error prone.

Rewrite routes give us so much more flexibility and control.

A rewrite route uses a Regexp object instead of a Controller and it will look something like this (let write this into our `routes.rb` file):

```ruby
Plezi.route ':locale', /^(en|fr|it)$/
Plezi.route '/', RootController
```

Let's restart our application and visit:

* [localhost:3000/](http://localhost:3000/)
* [localhost:3000/it](http://localhost:3000/it)
* [localhost:3000/fr](http://localhost:3000/fr)

Much better. Next step - let's fix use a template to render this in `html` format.

## Using templates

To use templates, we will need to update our Controller one last time (this will be our final code for the `hello_world` controller).

We will save the message in a variable we can access later and we'll use the `Controller#render` function to render an html template (our view):

```ruby
class RootController
  # HTTP
  def index
    # any String returned will be appended to the response. We return a String.
    @msg = case params['locale']
           when 'it'
             'Ciao mondo'
           when 'fr'
             'Salut le monde'
           else
             'Hello world'
           end
    render 'hello'
  end
end
```

Now our application is broken, because we are calling `render 'hello'`, but the `'hello'` template doesn't exist.

We will need to save a file named `'views/hello.html.erb'` in the `views` folder.

A few things about the file name (Plezi is a bit opinionated about it):

* `'hello'` is the name of the template. If the template were placed in a subfolder, the subfolder would have been attached to the name, i.e. `'subfolder/hello'`.

* `'html'` is the format of the rendered content. Later on we will create a template named `'hello.json.erb'`.

* `'erb'` is the rendering engine used for the file. Plezi supports `erb`, `slim` and `md` (markdown) out of the box, but we can add rendering engines as we please.

Here's what our simple `'views/hello.html.erb'` file looks like:

```html
<!DOCTYPE html>
<head>
<title><%= @msg %></title>
</head>
<body>
    <h1><%= @msg %></h1>
</body>
```

Cool, let's restart the application and see our work so far at:

* [localhost:3000/](http://localhost:3000/)
* [localhost:3000/it](http://localhost:3000/it)
* [localhost:3000/fr](http://localhost:3000/fr)

## Adding JSON

I promised three languages, so far so good.

But I also promised two output formats (html and JSON) using the same codebase for the controller... so how do we add JSON without changing our Controller's code?

Well, let's start with what we know. To control formatting we will want a `:format` parameter. We already know how to use rewrite routes.

Now our `routes.rb` file should look something like this:

```ruby
Plezi.route ':format', /^(html|json)$/
Plezi.route ':locale', /^(en|fr|it)$/
Plezi.route '/', RootController
```

We also know how to write templates, so let's add a JSON template. The file will be called `'views/hello.json.erb'` and it should look something like this:

```erb
<%= {message: @msg}.to_json %>
```

This is all we learned so far, so let see if that might be enough... let's restart the application try it:

* [localhost:3000/](http://localhost:3000/)
* [localhost:3000/html/fr](http://localhost:3000/html/fr)
* [localhost:3000/json/it](http://localhost:3000/json/it)

Wow, that's it. It actually works automatically, since the `:format` parameter is a reserved parameter for template formatting. This allows use to use a single controller codebase for different formats without doing a thing.

As you can see, the `html` format and the `en` locale are both optional, since they are the application's default values.

But what would happen if we tried requesting a format that we didn't support (no template provided)?

Let's edit our `routes.rb` to find out:

```ruby
Plezi.route ':format', /^(html|json|xml)$/
Plezi.route ':locale', /^(en|fr|it)$/
Plezi.route '/', RootController
```

Now, let's restart the application and try visiting [localhost:3000/xml/fr](http://localhost:3000/xml/fr).

## Handling errors

We hit an error, a missing page... it might be okay, but I do think that our xml request should get the error response as an xml document.

Let's create a file (a view / template will go in our `views` folder) named `'views/404.xml.erb'` with the following:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <status>404</status>
  <text>Not Found</text>
  <url><%= ::ERB::Util.h request.path_info %></url>
</error>
```

Now let's try this again: [localhost:3000/xml/fr](http://localhost:3000/xml/fr).

You might notice that the 404 error points at an empty request path (`/` instead of `/xml/fr`) - this is why we call them rewrite routes.

## Further exploration

There is much we didn't explore, such as setting cookies using the `cookie['name'] = "value"`, redirection (hint: `redirect_to`) and other cool tidbits. But we have enough to point us in the right direction.

I found, for myself, I learn best by simply doing, so I invite you to simply jump in the water.

On the other hand, if you're prefer reading some more, pick any of the Plezi guides and enjoy.
