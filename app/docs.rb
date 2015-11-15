# The basic website controller, to get you started
class DocsController
	# HTTP
	def index
		# return response << "Hello World!" # for a hello world app
		render :guides_index, layout: :layout
	end
	def show
		page = render ['guides', params[:id]]
		# Sometimes an encoding error would visit for no aparent reason... shouldn't happen... but...
		@title = (page.scan(/\<h1[^\>]*>([^\<]+)/) {|m| break m})[0] rescue nil
		render(:layout) { page }
	end
end



class NewPageLinksMDRenderer < Redcarpet::Render::HTML
	# Other methods where we don't return only a specific argument
	def link(link, title, content)
		"<a href=\"#{link}\"#{" target='_blank'" unless link[0] =~ /[\/\.]/}#{" title=\"#{title}\"" if title}>#{content}</a>"
	end
end


# # register the Github makrdown flavor renderer
# ::Plezi::Renderer.register :md do |filename, context, &block|
# 	Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, ::GitHub::Markup.render(filename) )  : (Plezi.get_cached filename)
# end

MD_RENDERER = Redcarpet::Markdown.new NewPageLinksMDRenderer.new(with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true
# MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML.new( with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true
MD_RENDERER_TOC = Redcarpet::Markdown.new Redcarpet::Render::HTML_TOC.new()
# register the Makrdown renderer with some Github flavors (but not the official Github Renderer)
::Plezi::Renderer.register :md do |filename, context, &block|
	data = IO.read filename
	Plezi.cache_needs_update?(filename) ? Plezi.cache_data( filename, "<div class='toc'>#{MD_RENDERER_TOC.render(data)}</div>\n#{::MD_RENDERER.render(data)}" )  : (Plezi.get_cached filename)
end