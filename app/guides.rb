# The basic website controller, to get you started
class GuidesController
	# HTTP
	def index
		# return response << "Hello World!" # for a hello world app
		render :guides_index, layout: :layout
	end
	def show
		render ['guides', params[:id]], layout: :layout
	end
end

# register the Github makrdown flavor renderer
::Plezi::Renderer.register :md do |filename, context, &block|
	Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, ::GitHub::Markup.render(filename) )  : (Plezi.get_cached filename)
end