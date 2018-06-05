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
    subscribe :chat
    publish :chat, "#{@name} joind the chat."
    write "Welcome, #{@name}!"
  end
  def on_close
    publish :chat, "#{@name} left the chat."
  end
  def on_message data
    # STDERR.puts "INFO: publishing message: #{@name}: #{data}"
    publish :chat, "#{@name}: #{::ERB::Util.html_escape data}"
    # STDERR.puts "INFO: published message (fin)."    
  end
  def on_shutdown
    write "--- SYSTEM ---"
    write "--- Server is going away (restarting / maintanence)..."
    write "--- See you later."
  end
end
