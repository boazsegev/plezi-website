---
title: WebSockets for Ruby made easy
toc: false
---

# {{title}}

## Easy WebSockets + Powerful Publish / Subscribe

Iodine (with or without Plezi) offers easy WebSockets and a powerful pub/sub solution for Ruby.

Add iodine to your favorite Framework or use it directly for a Rack application:

```ruby
require "iodine" # this config.ru example runs on iodine.

# A simple Websocket Callback Object.
module BroadcastClient
  # subscribe to new clients.
  def self.on_open client
    client.subscribe :broadcast
  end
  # send a message, letting the client know the server is shutting down.
  def self.on_shutdown client
    client.write "Server shutting down. Goodbye."
  end
  # broadcast incoming messages to chat
  def self.on_message client, data
    client.publish :broadcast, data
  end
end

# A simple router - Checks for Websocket Upgrade and answers HTTP.
module APP_EXAMPLE
  HTTP_RESPONSE = [200,
    { 'Content-Type' => 'text/html', 'Content-Length' => '32' },
    ['Please connect using websockets.'] ]
  WS_RESPONSE = [0, {}, []].freeze
  # this is function will be called by the Rack server (iodine) for every request.
  def self.call env
    # check if this is an upgrade request.
    if(env['rack.upgrade?'.freeze] == :websocket)
     env['rack.upgrade'.freeze] = BroadcastClient
     return WS_RESPONSE
    end
    # simply return the RESPONSE object, no matter what request was received.
    HTTP_RESPONSE
  end
end
# run this example rack app.
run APP_EXAMPLE
```

## Running Fast : plezi => iodine

The Plezi framework started out as an abstraction layer that used socket hijacking to make WebSockets for easy and seamless.

However, using the regular Ruby servers had a high performance penalty for a number of reasons - which is how iodine was born.

Performance issues were solved by unifying the IO engine for both HTTP and WebSockets and linking it together with the Pub/Sub registry within a new type of Ruby server - iodine.

Now everything can easily be done directly by using the optimized iodine server.

## How to install?

Simply install the `iodine` gem.

```bash
gem install iodine
```

## What about the Plezi gem?

As plezi evolved performance became critical, functionality moved from the framework directly into the `iodine` server. At this point the `plezi` gem should be considered a mere wrapper around `iodine`.
