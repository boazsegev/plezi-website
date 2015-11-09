# The "Hello World" OVERKILL!

If you read [the overview](/guides/basics), you know that a "Hello World" Plezi applicationonly needs two line (three, if you're using `irb` instead of a ruby script)... remember?

    require 'plezi'
    route('*') { "Hello World!" }
    exit # <- this exits the terminal and starts the server

So... what the hell do we have to write about? Well...

To make things more interesting, we're going to:

* Leverage a Controller class for our "Hello World".
* Use a template file to render our data.
* Use a layout for all our Html rendered pages (yes, there will be only one).
* Handle 404 errors gracefully.
* Add an AJAX JSON rewite-route to set our reponse format.
* Send the response in JSON format when requested.
* Install Github's render engine and use that instead of our original render engine (but we will keep the layout).

Hmmm... I'm still hinking about more ideas, but this seems like a fun start.

[todo: write the damn thing ;-)]
