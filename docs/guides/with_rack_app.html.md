# Using Plezi with our existing Rack application

Plezi can play well together with your existing Rack application, so we can run Plezi within our existing Rails/Sinatra/Rack application, adding websocket support to our existing code.

Plezi's server, [Iodine](https://github.com/boazsegev/iodine), isn't a [Rack](http://rack.github.io) server when Plezi uses it, but it _can_ be a Rack server as well... even while being used by Plezi at the same time.

This means that we can use Plezi for all our needs (Websockets, RESTful API, whatever), and still use our existing Rack application for anything we didn't implement in our Plezi code.

There's only one catch - we can't have more than a single web-server per application. This means that our existing Rack application **MUST** use Plezi (Iodine, actually) as it's web server.

If you really feel attached to your thin, unicorn, puma or passanger server, you can still integrate Plezi with your existing application, but they won't be able to share the same process and you will need to utilize the Placebo API (a guide is coming soon).

## How to add Plezi to our existing Rails/Sinatra/Rack app

First, make sure `plezi` and all the gems you need are included in your existin application's gemfile.

i.e., the `Gemfile` of a Rails app I upgraded to utilize Plezi websockets look something like this:

    gem 'plezi' # this was added for Plezi
    gem 'redis' # I was using Redis for scaling
    # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
    gem 'rails', '4.1.8'
    # Use sqlite3 as the database for Active Record
    gem 'sqlite3'
    # Use SCSS for stylesheets
    gem 'sass-rails', '~> 4.0.3'
    # ...

Next, include the Plezi application code within your existing application.

i.e., in my Rails app I added a `plezi.rb` file to the `config/initializers` folder, with my websocket code (which I won't share here). If I was using websockets to publish "news" to my users, the file might have looked something like this:

    class NewsPublisher
        def on_open
            @user = User.auth(params[:token])
            return close unless @user
            register_as @user.id
        end
        def on_message data
            # ignore, we only use the connection to send, not to receive.
        end
        protected
        def publish data
            write data
        end
    end
    route '/:token', NewsPublisher

Since both applications share the same code base, this example leveraged the model's `User#auth` to authenticate the connection using a temporary token.

I can also leverage `update` and `create` events in my Rails (or Sinatra) application to send websocket data to our users.

i.e.

    class NewsController < ApplicationController

      def create
          #...
          publish :new
      end

      def update
          #...
          publish :updated
      end

      protected

      def publish status
          data = {
            id: @news.id,
            author: @news.author.name,
            title: @news.title,
            status: status,
            url: url_for(@news)
          }.to_json

          @news.author.followers.each do |user|
              NewsPublisher.notify user.id, :publish, data
          end
      end

    end

Easy!

