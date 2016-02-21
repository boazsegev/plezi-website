# The basic website controller, to get you started
class DocsController
	# HTTP
	def index
		# return response << "Hello World!" # for a hello world app
		render :guides_index, layout: :layout
	end
	def show
		render ['guides', params['id']], layout: :layout
	end
end
