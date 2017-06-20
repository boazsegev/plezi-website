# Plezi - the Ruby framework for realtime web-apps
[![Gem Version](https://badge.fury.io/rb/plezi.svg)](http://badge.fury.io/rb/plezi) [![Inline docs](http://inch-ci.org/github/boazsegev/plezi.svg?branch=master)](http://www.rubydoc.info/github/boazsegev/plezi/master) [![GitHub](https://img.shields.io/badge/GitHub-Open%20Source-blue.svg)](https://github.com/boazsegev/plezi) <iframe src="https://ghbtns.com/github-btn.html?user=boazsegev&repo=plezi&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe>

Plezi is a Ruby framework for realtime web applications. It's name comes from the word "pleasure", since Plezi is a pleasure to work with.

With Plezi, you can easily:

1. Create a Ruby web application, taking full advantage of RESTful routing and scalable Websocket features;

2. Add Websocket services your existing Web-App, (Rails/Sinatra or any other Rack based Ruby app);

3. Create an easily scalable backend for your SPA.

You can start exploring demo code, guides and documentation using the links in the menu to your left. If you're using a small screen (i.e., mobile), you will need to click the top-left menu button to show the links.

## What does Plezi have to offer?

Plezi is a Rack based framework with support for native (server side implemented) Websockets.

Plezi will provide the following features over plain Rack:

* Object Oriented (M)VC / CRCA design with support for total separation between the application logic and the HTTP / Websocket layer.

* A case sensitive RESTful router to map HTTP requests to your Controllers.

    Non-RESTful public Controller methods will be automatically published as valid HTTP routes, allowing the Controller to feel like an intuitive "virtual folder" with RESTful features.

* Raw Websocket connections.

    Non-RESTful public Controller methods will be automatically published as valid HTTP routes, allowing the Controller to feel like an intuitive "virtual folder" with RESTful features.

* An (optional) Auto-Dispatch to map JSON websocket "events" to Controller functions (handlers).

* Pub/Sub support for the local process cluster using Iodine's native Pub/Sub support.

* Automatic (optional) scaling using Redis.

* An extensible template rendering abstraction engine, supports Slim, Markdown (using RedCarpet) and ERB out of the box.

* Belated, extensible, asset baking (a fallback for when the application's assets weren't baked before deployment).

    It's possible to define an asset route (this isn't the default) to bake assets on the fly.

    In production mode, assets will be baked directly to the public folder supplied to Iodine (the web server) with a matching path. This allows the static file server to serve future requests.

    However, during development, baking will save the files to the asset's folder, so that the Ruby layer will be the one serving the content and dynamic updates could be supported.

Things Plezi **doesn't** do (anymore / ever):

* No DSL. Plezi won't clutter the global namespace.

* No application logic inside.

    Connecting your application logic to Plezi is easy, however, application logic should really be *independent*, **reusable** and secure. There are plenty of gems that support independent application logic authoring.

* No native session support. If you *must* have session support, Rack middleware gems provide a lot of options. Pick one... However...

    Session have been proved over and over to be insecure and resource draining.

    Why use a session when you can save server resources and add security by using a persistent connection, i.e. a Websocket? If you really feel like storing unimportant stuff, why not use javascript's `local storage` on the *client's* machine? (if you need to save important stuff, you probably shouldn't be using sessions anyway).

* No code refresh / development mode. If you want to restart the application automatically whenever you update the code, there are probably plenty of gems that will take care of that.

Do notice, Websockets require Iodine (the server), since (currently) it's the only Ruby server known to support native Websockets using a Websocket Callback Object.

## Where Plezi comes from

The original inspiration for Plezi came to me when I was working with a friend on a game that used socket.io for the real-time communication.

Not only do I find Ruby is much more fun to work with, I also find some of socket.io's features to be quite vexing. I wanted more control over what was happening and most of all I wanted to avoid the amount of work Javascript was requiring for the most simple of tasks.

Plezi's goal were:

1. Support client to server and server to client communication in real-time.

	Since I had the model of an interactive game in my head, it was important that updates could be sent to the players in real-time and that the plays could push updates to the server without negotiating a new connection for each update.

2. Support client-(server)-client real-time communication.

	As games go, it was important that the player's "moves" could be made known to other players - maybe to one more player, maybe a group of specific players and maybe all the players, but this communication of messages between different connections had to be there.

3. Support easy scalability.

	I was really hoping my friend's game would be a wonderful success... and I wanted to think that all the games or applications that will be written using Plezi would also find success. It was important to me that the applications written using Plezi would be easy to scale as more users enjoyed them.

4. Allow easy fallback to AJAX (AJAJ actually) when websockets wasn't accessible... BUT without taking away from the programmer's control over the choice of the underlying architecture - some features you only want available on real-time and long-polling should be minimized whenever possible.

	At the time, Websockets weren't as common or as well supported as today. For this reason, I wanted it to be easy to use the same code for both types of communication and keep things a bit more DRY.

	This is why there aren't "websocket-controllers" and "http-controllers" - a controller can do both and also use it's HTTP methods for websocket data and events.

5. Another thing that was important for me was to have a 'diet-Rails' alternative. As Ruby on Rails was getting more mature it was also getting more complicated and bloated. Now, that Rails 5 is finally out, I feel even more strongly about this.

    I guess I wanted a light synthetic sugar layer over Rack that will let me use Websockets and support a design that truly separates the transport layer (HTTP / Websocket / terminal text input) from the application logic and code.

I wanted Plezi to be easy... and it is.

Plezi is so easy, you can write and run a whole application in a small script file, or even the `irb` terminal, if you like - try doing that with Rails or Sinatra, see where that gets you ;-)

## Start exploring

To your left you will find a menu with the list of available guides and demo code.

To start up, make sure you [installed Plezi](/docs/install).

Next, read [the Getting Started overview](/docs/basics) and try the demo code as you follow along.

To learn more about using templates, Controllers and graceful error handling for Plezi's RESTful and Http features, read through our [Hello World OVERKILL](/docs/hello_world) tutorial, as it contains much more than a simple "Hello World".

Our [Websocket chatroom](/docs/hello_chat) tutorial will explain the code I posted on the landing page and show you how to leverage JSON on both the client and the server.

This should get your apetite running and you'll be peeking at our more in-depth documentation in no-time.

## The table of contents

To your right you'll find a floating "Table of Contents" for the document your reading. Hover above it with your mouse (or touch it) if you want to skip between sections of the same document.

## Please excuse us while we write

This website and the guides are being rewritten for Plezi 0.15.0 (which is revolutionized by it's native Pub/Sub support and performace) and we're still writing everything down...

...and when I say that "we" are still writing everything down, it's because I invite you to join in on the writing and help document Plezi's different features.

We need editors to edit the existing documentation, writers to add more interesting tutorials and good people who are happy to help - even fixing ==~~taipos~~== typos.

---

[This website's source and all the guides are hosted with Github. Please fork, edit and create pull requests!](https://github.com/boazsegev/plezi-website)
