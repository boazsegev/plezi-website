<!--<PageMap>
    <DataObject type="document">
        <Attribute name="title">A Ruby Websocket Chat with Plezi</Attribute>
        <Attribute name="author">Bo (Myst)</Attribute>
        <Attribute name="description">
            In this tutorial we explore how to quickly write a Ruby websocket chatroom applications using Plezi.
        </Attribute>
    </DataObject>
    <DataObject type="thumbnail">
        <Attribute name="src" value="http://localhost:3000/images/logo_thick_dark.png" />
        <Attribute name="width" value="656" />
        <Attribute name="height" value="256" />
    </DataObject>
</PageMap>-->
# The Chatroom Experience

Plezi's 0.15.0 release and Iodine's new Pub/Sub features, replaced Plezi's previous (powerful, yet less common) approach to Websockets client communication.

This means that this section should be rewritten from the ground up.

This might take a while.

For now, I will leave you with some code for a Plezi client (HTML / Javascript) and a Plezi server.

## The Client Code

The following is the HTML / Javascript client part of the code.

I used the optional `PleziClient` just to keep the code a bit shorter, but Plezi works with any Websocket client.

```html
<!DOCTYPE html>
<html>
<title>The Chatroom Example</title>
<head>
  <script src='/javascripts/client.js'></script>
  <script>
  // the client object
  client = NaN;
  // A helper function to print messages to a DIV called "output"
  function print2output(text) {
      var o = document.getElementById("output");
      o.innerHTML = "<li>" + text + "</li>" + o.innerHTML
  }
  // A helper function to disable a text input called "input"
  function disable_input() {
      document.getElementById("input").disabled = true;
  }
  // A helper function to enable a text input called "input"
  function enable_input() {
      document.getElementById("input").disabled = false;
      document.getElementById("input").placeholder = "Message";
  }
  // A callback for when our connection is established.
  function connected_callback(event) {
      enable_input();
      print2output("System: " + client.nickname + ", welcome to the chatroom.");
  }
  // creating the client object and connecting
  function connect2chat(nickname) {
      // create a global client object. The default connection URL is the same as our Controller's URL.
      // the optional PleziClient uses a Websocket connection with automated JSON event routing (auto-dispatch).
      client = new PleziClient();
      // save the nickname
      client.nickname = nickname;
      // Set automatic reconnection. This is great when a laptop or mobile phone is closed.
      client.autoreconnect = true
      // handle connection state updates
      client.onopen = function(event) {
          client.was_closed = false;
          // when the connection opens, we will authenticate with our nickname.
          // This isn't really authenticating anything, but we can add security logic later.
          client.emit({
              event: "chat_auth",
              nickname: client.nickname
          }, connected_callback);
      };
      // handle connection state updates
      client.onclose = function(event) {
          if (client.was_closed) return;
          print2output("System: Connection Lost.");
          client.was_closed = true;
          disable_input();
      };
      // handle the chat_message event
      client.chat_message = function(event) {
          if(client.user_id == event.user_id)
            event.name = "Me";
          print2output(event.name + ": " + event.message)
      };
      // handle the chat_login event
      client.chat_login = function(event) {
          if(!client.id && client.nickname == event.name)
            client.user_id = event.user_id;
          print2output("System: " + event.name + " logged into the chat.")
      };
      // handle the chat_logout event
      client.chat_logout = function(event) {
          print2output("System: " + event.name + " logged out of the chat.")
      };
      return client;
  }
  // This will be used to send the text in the `input` to the websocket.
  function send_text() {
      // get the text
      var msg = document.getElementById("input").value;
      // clear the input field
      document.getElementById("input").value = '';
      // no client? the text is the nickname.
      if (!client) {
          // connect to the chat
          connect2chat(msg);
          // prevent default action (form submission)
          return false;
      }
      // there is a client, the text is a chat message.
      client.emit({
          event: "chat_message",
          message: msg
      });
      // prevent default action (avoid form submission)
      return false;
  }
  </script>
    <style>
    html, body {width:100%; height: 100%; background-color: #ddd; color: #111;}
    h3, form {text-align: center;}
    input {background-color: #fff; color: #111; padding: 0.3em;}
    </style>
</head><body>
  <h3>The Chatroom Example</h3>
    <form id='form' onsubmit='send_text(); return false;'>
        <input type='text' id='input' name='input' placeholder='nickname'></input>
        <input type='submit' value='send'></input>
    </form>
    <script> $('#form')[0].onsubmit = send_text </script>
    <ul id='output'></ul>
</body>
</html>
```

## The Server code

The server code is significantly shorter, since Ruby code is often more concise than Javascript and because all the "display" (formatting) logic is naturally offloaded to the client side.

Offloading the "rendering" to the client side application provides a better resource distribution and allows the server to focus on the important stuff.

```ruby
# Server
require 'plezi'
class MyChatroom
  # HTTP
  def index
    # Normally, the client would be served as a static, pre-compressed, file.
    # However, for this example we will return the whole client as a Ruby string.
    CLIENT_AS_STRING
  end

  # Websocket / AJAJ
  @auto_dispatch = true

  def chat_auth event
    if params[:nickname] || (::ERB::Util.h(event[:nickname]) == "Me")
      # Not allowed (double authentication / reserved name)
      close
      return
    end
    # set our ID and subscribe to the chatroom's channel
    params[:nickname] = ::ERB::Util.h event[:nickname]
    subscribe :chat
    # publish the new client's presence.
    publish :chat, {event: 'chat_login',
                    name: params[:nickname],
                    user_id: id}.to_json
    # if we return an object, it will be sent to the websocket client.
    nil
  end
  def chat_message msg
    # prevent false identification
    msg[:name] = params[:nickname]
    msg[:user_id] = id
    # publish the chat message
    publish :chat, msg.to_json
    nil
  end
  def on_close
    # inform about client leaving the chatroom
    publish :chat, {event: 'chat_logout',
                    name: params[:nickname],
                    user_id: id}.to_json
  end
end

Plezi.route "/javascripts/client.js", :client
Plezi.route '/(:nickname)', MyChatroom

exit
```

## All Together

It's possible to run the whole thing from the terminal by copying and pasting the following code:

```ruby
# Client
CLIENT_AS_STRING = <<EOM
<!DOCTYPE html>
<html>
<title>The Chatroom Example</title>
<head>
  <script src='/javascripts/client.js'></script>
  <script>
  // the client object
  client = NaN;
  // A helper function to print messages to a DIV called "output"
  function print2output(text) {
      var o = document.getElementById("output");
      o.innerHTML = "<li>" + text + "</li>" + o.innerHTML
  }
  // A helper function to disable a text input called "input"
  function disable_input() {
      document.getElementById("input").disabled = true;
  }
  // A helper function to enable a text input called "input"
  function enable_input() {
      document.getElementById("input").disabled = false;
      document.getElementById("input").placeholder = "Message";
  }
  // A callback for when our connection is established.
  function connected_callback(event) {
      enable_input();
      print2output("System: " + client.nickname + ", welcome to the chatroom.");
  }
  // creating the client object and connecting
  function connect2chat(nickname) {
      // create a global client object. The default connection URL is the same as our Controller's URL.
      client = new PleziClient();
      // save the nickname
      client.nickname = nickname;
      // Set automatic reconnection. This is great when a laptop or mobile phone is closed.
      client.autoreconnect = true
          // handle connection state updates
      client.onopen = function(event) {
          client.was_closed = false;
          // when the connection opens, we will authenticate with our nickname.
          // This isn't really authenticating anything, but we can add security logic later.
          client.emit({
              event: "chat_auth",
              nickname: client.nickname
          }, connected_callback);
      };
      // handle connection state updates
      client.onclose = function(event) {
          if (client.was_closed) return;
          print2output("System: Connection Lost.");
          client.was_closed = true;
          disable_input();
      };
      // handle the chat_message event
      client.chat_message = function(event) {
          if(client.user_id == event.user_id)
            event.name = "Me";
          print2output(event.name + ": " + event.message)
      };
      // handle the chat_login event
      client.chat_login = function(event) {
          if(!client.id && client.nickname == event.name)
            client.user_id = event.user_id;
          print2output("System: " + event.name + " logged into the chat.")
      };
      // handle the chat_logout event
      client.chat_logout = function(event) {
          print2output("System: " + event.name + " logged out of the chat.")
      };
      return client;
  }
  // This will be used to send the text in the `input` to the websocket.
  function send_text() {
      // get the text
      var msg = document.getElementById("input").value;
      // clear the input field
      document.getElementById("input").value = '';
      // no client? the text is the nickname.
      if (!client) {
          // connect to the chat
          connect2chat(msg);
          // prevent default action (form submission)
          return false;
      }
      // there is a client, the text is a chat message.
      client.emit({
          event: "chat_message",
          message: msg
      });
      // prevent default action (avoid form submission)
      return false;
  }
  </script>
    <style>
    html, body {width:100%; height: 100%; background-color: #ddd; color: #111;}
    h3, form {text-align: center;}
    input {background-color: #fff; color: #111; padding: 0.3em;}
    </style>
</head><body>
  <h3>The Chatroom Example</h3>
    <form id='form' onsubmit='send_text(); return false;'>
        <input type='text' id='input' name='input' placeholder='nickname'></input>
        <input type='submit' value='send'></input>
    </form>
    <script> $('#form')[0].onsubmit = send_text </script>
    <ul id='output'></ul>
</body>
</html>
EOM


# Server
require 'plezi'
class MyChatroom
  # HTTP
  def index
    # Normally, the client would be served as a static, pre-compressed, file.
    # However, for this example we will return the whole client as a Ruby string.
    CLIENT_AS_STRING
  end

  # Websocket / AJAJ
  @auto_dispatch = true

  def chat_auth event
    if params[:nickname] || (::ERB::Util.h(event[:nickname]) == "Me")
      # Not allowed (double authentication / reserved name)
      close
      return
    end
    # set our ID and subscribe to the chatroom's channel
    params[:nickname] = ::ERB::Util.h event[:nickname]
    subscribe :chat
    publish :chat, {event: 'chat_login',
                    name: params[:nickname],
                    user_id: id}.to_json
    # if we return an object, it will be sent to the websocket client.
    nil
  end
  def chat_message msg
    # prevent false identification
    msg[:name] = params[:nickname]
    msg[:user_id] = id
    publish :chat, msg.to_json
    nil
  end
  def on_close
    publish :chat, {event: 'chat_logout',
                    name: params[:nickname],
                    user_id: id}.to_json
  end
end

Plezi.route "/javascripts/client.js", :client
Plezi.route '/(:nickname)', MyChatroom

exit
```
