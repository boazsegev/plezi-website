# A custom render engine that makes sure links to foriegn sites open in a new window/tab.
class NewPageLinksMDRenderer < Redcarpet::Render::HTML
	# review's the link and renders the Html
	def link(link, title, content)
		"<a href=\"#{link}\"#{" target='_blank'" if link =~ /^http[s]?\:\/\//}#{" title=\"#{title}\"" if title}>#{content}</a>"
	end
end

# create a single gloabl renderer for all markdown files.
MD_RENDERER = Redcarpet::Markdown.new NewPageLinksMDRenderer.new(with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true

# create a single gloabl renderer for all markdown TOC.
MD_RENDERER_TOC = Redcarpet::Markdown.new Redcarpet::Render::HTML_TOC.new()

# register the Makrdown renderer with some Github flavors (but not the official Github Renderer)
::Plezi::Renderer.register :md do |filename, context, &block|
	if Plezi.cache_needs_update?(filename)
		data = IO.read filename
		data = Plezi.cache_data( filename, "<div class='toc'>#{MD_RENDERER_TOC.render(data)}</div>\n#{::MD_RENDERER.render(data)}" )
		context.receiver.instance_variable_set :@title, Plezi.cache_data("#{filename}_title".freeze, ((data.scan(/\<h1[^\>]*>([^\<]+)/) {|m| break m})[0] rescue nil))
		data
	else
		context.receiver.instance_variable_set :@title, Plezi.get_cached("#{filename}_title".freeze)
		Plezi.get_cached(filename)
	end
end


# # The following line was used before link rendering was customized:
# MD_RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML.new( with_toc_data: true), autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true, footnotes: true
