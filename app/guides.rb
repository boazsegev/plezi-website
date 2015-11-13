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

# # register the Github makrdown flavor renderer
# ::Plezi::Renderer.register :md do |filename, context, &block|
# 	Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, ::GitHub::Markup.render(filename) )  : (Plezi.get_cached filename)
# end

MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML.new( with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true
# MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML, with_toc_data: true, autolink: true, fenced_code_blocks: true
MD_RENDERER_TOC = Redcarpet::Markdown.new Redcarpet::Render::HTML_TOC.new()
# register the Makrdown renderer with some Github flavors (but not the official Github Renderer)
::Plezi::Renderer.register :md do |filename, context, &block|
	data = IO.read filename
	Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, "<div class='toc'>#{MD_RENDERER_TOC.render(data)}</div>\n#{::MD_RENDERER.render(data)}" )  : (Plezi.get_cached filename)
end