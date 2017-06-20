# The basic website controller, to get you started
class HomeController
  # HTTP
  def index
    # cookies['last_nickname'.freeze] = nil
    render('layout') { render 'welcome' }
  end

  # def pre_connect
  #   cookies['last_nickname'.freeze] = params['id'.freeze]
  # end

  # Websockets
  def on_open
    return close unless params['id']
    @name = ::ERB::Util.html_escape params['id']
    subscribe channel: "chat"
    publish channel: "chat", message: "#{@name} joind the chat."
    write "Welcome, #{@name}!"
  end
  def on_close
    publish channel: "chat", message: "#{@name} joind the chat."
  end
  def on_message data
    publish channel: "chat", message: "#{@name}: #{::ERB::Util.html_escape data}"
  end
end
