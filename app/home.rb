# The basic website controller, to get you started
class HomeController
  # HTTP
  def index
    # return response << "Hello World!" # for a hello world app
    render('layout') { render 'welcome' }
  end

  # Websockets
  def on_open
    return close unless params['id'.freeze]
    broadcast :print, "#{params['id'.freeze]} joind the chat."
    print "Welcome, #{params['id'.freeze]}!"
  rescue => e
    puts e.message, e.backtrace
  end

  def on_close
    broadcast :print, "#{params['id'.freeze]} left the chat."
  end

  def on_message(data)
    self.class.broadcast :print, "#{params['id'.freeze]}: #{data}"
  end

  protected

  def print(data)
    write ::ERB::Util.html_escape(data)
  end
end
