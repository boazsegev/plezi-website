# The basic website controller, to get you started
class DocsController
	# HTTP
	def index
		# return response << "Hello World!" # for a hello world app
		render :guides_index, layout: :layout
	end
	def show
		page = render ['guides', params[:id]]
		return false unless page
		# Sometimes an encoding error would pop up for no aparent reason... rescue shouldn't happen... but...
		@title = (page.scan(/\<h1[^\>]*>([^\<]+)/) {|m| break m})[0] rescue nil
		render(:layout) { page }
	end
end