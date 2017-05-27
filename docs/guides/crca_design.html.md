# Modular CRCA design with Ruby and Plezi

CRCA design follows the long-term OOP SOLID design philosophy, applying it to web framework design.

By following the CRCA design, applications become easier to test and maintain, relieving the application's dependency on the client side code, the framework or the server.

CRCA stands for the decoupling and flow control between **C**lient, **R**outer, **C**ontroller and **A**pplication. <!-- s** !-->

Each of these elements has a different, yes single, responsibility.

* The **Client** is only responsible for user friendly access to the public facing API.

 Obviously this encapsulates the whole user experience (UX). It is a high level concern that will be broken down.

 i.e., if the client happens to be a browser, it will probably delegate the task to the HTML, CSS and JavaScript layers, breaking it down to smaller components.

 But in essence it comes down to invoking the application's public facing API using the router - everything else is sugar.

* The **Router** is only responsible for routing the Client's request to the correct Controller.

 This allows each Controller to handle a single higher level responsibility.

 Hence, the client only needs to know how to invoke the API using the router. The client doesn't need to know anything about the application API (and it probably shouldn't know anything about the application's API).

* The **Controller** has the single responsibility of translating between the transport layer (the information received through the router) and the application's API.

 This means that the Controller's single concern - that of translation - protects against any entanglement between the Application layer and the Router/Client layers.

* The **Application**(s) has the single responsibility of implementing the API required to execute the business logic.

 That's all.

 The application shouldn't care if the returned value is printed on a terminal screen or sent to a remote machine. The application layer should have nothing to do with the transport layer (the Router) or the UI (the Client).

This design allows a strong decoupling between the application and web framework, so tests and business logic development can run at blazing speeds, making maintenance a breeze.

No more need to emulate any transport layer details (such as fake HTTP requests) or to load a whole web framework / server to test the application's code.

## Where does the web-framework fit in?

The web framework's single responsibility is the Router/Controller relationship.

The framework shouldn't enforce the routes nor author the controllers, but it should make sure that the relationship between these two is flawless and easy to manage.

The web framework should route requests from the client to the appropriate Controller and return the responses so the server can send them back to the client.

As a matter of convenience, the web framework should probably provide helpers for common "translation" related tasks (i.e., template rendering, etc'), as well as helpers for transport related events (push, pub/sub, etc').

That's all.

The web framework is NOT a web server (although it's often run on a server), so it shouldn't be in charge of client related "assets" etc'. It is better if these things are served directly by the web server, even if during development it is comfortable to serve these through the framework.

## Why not MVC?

Every Rails developer that had to maintain a large Rails application experienced the high technical debt inherent to the MVC design.

Theory aside - experience shows that this design approach failed time after time.

The reasons are plentiful. But in short, MVC design is a UI pattern design.

MVC comes from UI design for native applications (Windows/macOS etc) and was never meant to be extended to the actual application logic.

When the design was implemented in these circumstances, the Model was in charge of UI presentation state and logic. Any actual business logic would be (or should have been) handled separately in the part of the code that was the actual application (not it's UI).

The MVC design pattern should be applied to the Client, not the web framework and definitely not the actual application.

A short search of the internet exposes many good resources that often describe the downfalls inherent in this design when it's extended beyond the UI layer. Such as [this stack-exchange discussion](https://softwareengineering.stackexchange.com/questions/207620/what-are-the-downfalls-of-mvc).

## How does Plezi help?

Plezi helps by limiting itself to the web framework's concern - the Router/Controller relationship.

By doing less, Plezi allows the application's code to be totally decoupled from the framework.

If the application needs a database, it's free to use any general ORM such as `ActiveRecord` or `Squel` or even use database and SQL requests directly.

We, at Plezi, love freedom and love the amazing Ruby community and Open Source gems, we love `dry-rb` and the concept behind it, and we believe that the best way a framework could help your Ruby application to maximize it's potential, is by staying out of your way and keeping to the single responsibility of managing the Router-Controller relationship.

## Where does the term CRCA come from?

You wonder why you never heard the term CRCA before? Well, even if the name is new, the approach is old. People seem to have forgotten it's importance, so I thought an acronym might help. You can view [Robert Martin's Keynote, Architecture the Lost Years](https://youtu.be/WpkDN78P884), to learn more.
