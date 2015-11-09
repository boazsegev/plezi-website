# The basic website controller, to get you started
class HomeController
	# HTTP
	def index
		# return response << "Hello World!" # for a hello world app
		render :welcome, layout: :layout
	end
	# Websockets
	def on_open
		return close unless params[:id]
		broadcast :print, "#{params[:id]} joind the chat."
		print "Welcome, #{params[:id]}!"
	end
	def on_close
		broadcast :print, "#{params[:id]} left the chat."
	end
	def on_message data
		self.class.broadcast :print, "#{params[:id]}: #{data}"
	end
	protected
	def print data
		write ::ERB::Util.html_escape(data)
	end
end